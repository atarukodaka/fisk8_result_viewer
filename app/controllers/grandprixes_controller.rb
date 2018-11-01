class GrandprixesController < ApplicationController
  using StringToModel
  include DebugPrint
  POINT_MAPPINGS = [0, 15, 13, 11, 9, 7, 5, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].freeze
  def index
    season = SkateSeason.new(params[:season] || '2018-19')
    category = (params[:category_name] || 'MEN').to_category

    events = GrandprixEvent.where(season: season.to_s, category: category)
             .includes(:grandprix_entries, grandprix_entries: [:skater])

    skaters = events.includes(:skaters).map(&:skaters).flatten.uniq
    results = {}
    skaters.each do |skater|
      results[skater] = { points: Array.new(6) { 0 }, accumulated_points: Array.new(6) { 0 },
                          participated: Array.new(6) { false },
                          probability_to_qualify: 0.0,  }
    end

    last_season = SkateSeason.new(season.start_date.year - 1)
    average_scores = CategoryResult.where("competitions.season": last_season.to_s).qualified
                     .joins(:competition).group(:skater).average(:points)

    num_simulation = [(params[:simulation_times] || 100).to_i, 1000].min
    bell = RandomBell.new(mu: 0, sigma: 1)
    stddev_ratio = (params[:stddev_ratio] || 0.2).to_f

    qualified = Hash.new { 0 }

    num_simulation.times do |_i|
      ## do simulation
      events.each do |event|
        if event.done?
          event.grandprix_entries.each do |entry|
            results[entry.skater][:points][entry.grandprix_event.number - 1] = entry.point
            results[entry.skater][:accumulated_points][entry.grandprix_event.number - 1] += entry.point
            results[entry.skater][:participated][entry.grandprix_event.number - 1] = true
          end
          next
        end

        scores = {}
        event.grandprix_entries.each do |entry|
          avg = average_scores[entry.skater] || 0.0
          scores[entry.skater] = avg + bell.rand * stddev_ratio * avg
          #Rails.logger.debug("#{entry.skater.name}: #{scores[entry.skater]}")
        end

        scores.sort_by { |_k, v| v }.reverse_each.with_index(1) do |(skater, _score), ranking|
          results[skater][:points][event.number - 1] = POINT_MAPPINGS[ranking]
          results[skater][:accumulated_points][event.number - 1] += POINT_MAPPINGS[ranking]
          results[skater][:participated][event.number - 1] = true
        end
      end

      results.each do |skater, hash|
        results[skater][:total] = hash[:points].sum
        results[skater][:points] = []
        results[skater][:accumulated_points].each.with_index do |point, i|
          results[skater][:points][i] = point.to_f / num_simulation.to_f
        end
      end
      final_rankings = results.sort_by { |_k, v| v[:total] }.reverse.map { |d| d[0] }
      final_rankings[0..5].each do |skater|
        qualified[skater] += 1
      end
    end
    qualified.each do |skater, num_qualified|
      results[skater][:probability_to_qualify] = num_qualified.to_f / num_simulation
    end
    results.sort_by { |_skater, hash| hash[:probability_to_qualify] }.reverse_each.with_index(1) do |arr, ranking|
      arr[1][:ranking] = ranking
    end
    render :index, locals: { season: season, category: category, events: events, results: results,
                             simulation_parameters: { times: num_simulation, stddev_ratio: stddev_ratio } }
  end
end
