class GrandprixSimulator
  POINT_MAPPINGS = [0, 15, 13, 11, 9, 7, 5, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].freeze
  MAX_NUM_SIMULATIONS = 10000

  def bell
    @bell ||= RandomBell.new(mu: 0, sigma: 1)
  end

  def run(events, parameters: {})
    done_events = events.where(done: true)
    incoming_events = events.where(done: false)

    last_season = SkateSeason.new(events.first.season) - 1
    average_scores = CategoryResult.where("competitions.season": last_season.to_s).qualified
                     .joins(:competition).group(:skater).average(:points)

    points = Hash.new { |h, k| h[k] = Array.new(6) { 0 } }
    accum_points = Hash.new { |h, k| h[k] = Array.new(6) { 0 } }
    qualified = Hash.new { 0 }

    ## parameters
    num_simulations = [parameters[:times].to_i, MAX_NUM_SIMULATIONS].min
    stddev_to_ratio = parameters[:stddev_to_ratio] || 0.2

    done_events.each do |event|
      event.grandprix_entries.each do |entry|
        points[entry.skater][event.number - 1] = entry.point
      end
    end

    num_simulations.times do |_i|
      sim_points = points.dup

      ## competitions not yet done
      incoming_events.each do |event|
        scores = {}
        event.grandprix_entries.each do |entry|
          avg = average_scores[entry.skater] || 0.0
          scores[entry.skater] = avg + bell.rand * stddev_to_ratio * avg
        end
        scores.sort_by { |_k, v| v }.reverse_each.with_index(1) do |(skater, _score), ranking|
          sim_points[skater][event.number - 1] = POINT_MAPPINGS[ranking]
          accum_points[skater][event.number - 1] += POINT_MAPPINGS[ranking]
        end
      end
      ## total points
      total_points = {}
      sim_points.each do |skater, arr|
        total_points[skater] = arr.map(&:to_i).sum
      end
      ## rankings / qualified
      rankings = total_points.sort_by { |_k, v| v }.reverse.map { |d| d[0] }
      rankings[0..5].each do |skater|
        qualified[skater] += 1
      end
    end   ## sim

    ## calculate average points
    incoming_events.each do |event|
      event.grandprix_entries.each do |entry|
        points[entry.skater][event.number - 1] =
          accum_points[entry.skater][event.number - 1].to_f / num_simulations
      end
    end

    results = {}
    skaters = events.includes(:skaters).map(&:skaters).flatten.uniq
    skaters.each do |skater|
      results[skater] = {
        points: points[skater],
        participated: [],
        probability_to_qualify: qualified[skater].to_f / num_simulations,
      }
    end

    incoming_events.each do |event|
      event.grandprix_entries.each do |entry|
        results[entry.skater][:participated][event.number - 1] = true
      end
    end

    results
  end
end
