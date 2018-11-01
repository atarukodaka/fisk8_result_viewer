class GrandprixesController < ApplicationController
  using StringToModel
  include DebugPrint

  def index
    points_mappings = [0, 15, 13, 11, 9, 7, 5, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    season = SkateSeason.new('2018-19')
    category = (params[:category_name] || 'MEN').to_category

    events = GrandprixEvent.where(season: season.to_s, category: category).includes(:grandprix_entries, grandprix_entries: [ :skater ] )
    #points_by_skaters = {}
    #probability_by_skaters = {}
    
    skaters = events.includes(:skaters).map {|e| e.skaters}.flatten.uniq
    results = {}
    #average_score_by_skaters = {}
    skaters.each do |skater|
      results[skater] = { points: Array.new(6){ 0}, accumulated_points: Array.new(6) {0},
                          participated: Array.new(6) { false },
                          probability_to_qualify: 0.0,
                        }
    end

    average_scores = CategoryResult.where("competitions.season": SkateSeason.new(season.start_date.year-1).to_s).qualified.joins(:competition).group(:skater).average(:points)
    #binding.pry
    num_simulation = [(params[:simulation_times] || 100).to_i, 1000].min
    bell = RandomBell.new(mu: 0, sigma: 1)
    stddev_ratio = (params[:stddev_ratio] || 0.2).to_f
    
    qualified = Hash.new { 0 }

    num_simulation.times do |i|
      ## do simulation
      events.each do |event|
        if event.done?
          event.grandprix_entries.each do |entry|
            results[entry.skater][:points][entry.grandprix_event.number-1] = entry.point
            results[entry.skater][:accumulated_points][entry.grandprix_event.number-1] += entry.point            
          end
          next
        end

        scores = {}
        event.grandprix_entries.each do |entry|
          avg = average_scores[entry.skater] || 0.0
          scores[entry.skater] =  avg + bell.rand * stddev_ratio * avg
          #Rails.logger.debug("#{entry.skater.name}: #{scores[entry.skater]}")
        end

        scores.sort_by {|_k, v| v}.reverse.each.with_index(1) do |(skater, score), ranking|
          #sim_points[skater] = points_mapping[ranking]
          #sim_accum_points[skater] += points_mappings[ranking]
          results[skater][:points][event.number-1] = points_mappings[ranking]
          results[skater][:accumulated_points][event.number-1] += points_mappings[ranking]
          results[skater][:participated][event.number-1] = true
        end
      end
      
      #final_rankings = points_by_skaters.sort_by {|_s, d| d.sum}.reverse
      results.each do |skater, hash|
        results[skater][:total] = hash[:points].sum
        results[skater][:simulated_points] = []
        results[skater][:accumulated_points].each.with_index do |point, i|
          results[skater][:simulated_points][i] = point.to_f / num_simulation.to_f
        end
      end
      final_rankings = results.sort_by {|k, v| v[:total]}.reverse.map {|d| d[0]}
      #final_rankings = results.map {|s, hash| [s, hash[:points].sum]}.sort {|a| a[1]}.reverse.map {|a| a[0]}
      final_rankings[0..5].each do |skater|
        qualified[skater] += 1
      end
    end
    qualified.each do |skater, num_qualified|
      results[skater][:probability_to_qualify] = num_qualified.to_f / num_simulation
    end
    
    render :index, locals: { season: season, category: category, events: events, results: results,
                             simulation_parameters: { times: num_simulation, stddev_ratio: stddev_ratio}}
  end
end
