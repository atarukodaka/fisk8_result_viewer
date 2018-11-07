class GrandprixSimulator
  POINT_MAPPINGS = [0, 15, 13, 11, 9, 7, 5, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].freeze
  MAX_NUM_SIMULATIONS = 1000

  def bell
    @bell ||= RandomBell.new(mu: 0, sigma: 1)
  end

  def get_average_scores_by_skater(events)
    last_season = SkateSeason.new(events.first&.season) - 1
    CategoryResult.where("competitions.season": last_season.to_s).qualified
      .joins(:competition).group(:skater).average(:points)
  end

  def update_qualified(sim_points, qualified)
    ## total points
    total_points = sim_points.map do |skater, arr|
      { skater: skater, total_point: arr.map(&:to_i).sum }
    end
    ## rankings / qualified
    total_points.sort_by { |h| h[:total_point] }.reverse_each.with_index(1) do |hash, ranking|
      break if ranking >= 6

      qualified[hash[:skater]] += 1
    end
  end

  def run(events, parameters: {})
    done_events = events.done
    incoming_events = events.incoming
    average_scores = get_average_scores_by_skater(events)

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

    num_simulations.times do   ## run for incoming competitions
      sim_points = points.dup

      incoming_events.each do |event|
        scores = event.grandprix_entries.map do |entry|
          avg = average_scores[entry.skater] || 0.0
          { skater: entry.skater, score: avg + bell.rand * stddev_to_ratio * avg }
        end
        scores.sort_by { |h| h[:score] }.reverse_each.with_index(1) do |hash, ranking|
          point = POINT_MAPPINGS[ranking]
          sim_points[hash[:skater]][event.number - 1] = point
          accum_points[hash[:skater]][event.number - 1] += point
        end
      end
      update_qualified(sim_points, qualified)
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
