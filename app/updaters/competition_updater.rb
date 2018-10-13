class CompetitionUpdater < Updater
  using StringToModel
  include CompetitionUpdater::Deviations
  include CompetitionUpdater::Results
  include CompetitionUpdater::Scores
  include CompetitionUpdater::Utils

  def clear_existing_competitions(site_url)
    ActiveRecord::Base.transaction do
      Competition.where(site_url: site_url).map(&:destroy)
    end
  end

  def update_competition_attributes(competition, summary, params: {})
    slice_common_attributes(competition, summary).tap do |hash|
      competition.attributes = hash
      params.reject { |_k, v| v.blank? }.each do |key, value|
        competition[key] = value          ## TODO: check if it works
      end
    end
    competition.country ||= CityCountry.find_by(city: competition.city).try(:country)
    [:start_date, :end_date, :timezone].each do |key|
      # competition[key] =  summary[:time_schedule].send(key)
      competition[key] =  summary.send(key)
    end
  end

  def categories_to_update(categories1, categories2)
    return categories2.map(&:to_category).compact  if categories1.nil?

    (Array(categories1) & Array(categories2)).map(&:to_category).compact
  end

  ################
  def update_competition(site_url, opts = {})
    debug("update competition with site_url of: #{site_url}")
    default_options = { date_format: nil, force: nil, categories: nil,
                        season_from: nil, season_to: nil, params: {} }
    options = default_options.merge(opts)
    if (!options[:force]) && (comps = Competition.where(site_url: site_url).presence)
      debug("  .. skip: already existing: #{site_url}")
      return comps.first
    end

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)
      summary = parser(:summary, parser_type: options[:parser_type])
                .parse(site_url, date_format: options[:date_format]) || return
      summary.season.between?(options[:season_from], options[:season_to]) ||
        begin
          debug('skip: season out of range ')
          return
        end

      competition = Competition.create! do |comp|
        update_competition_attributes(comp, summary, params: options[:params])
      end
      debug('*' * 100)
      debug('%<name>s [%<short_name>s] (%<site_url>s)' % competition.attributes.symbolize_keys)

      categories_to_update(options[:categories], summary.categories).each do |category|
        update_category_results(competition, category, summary.category_result_url(category.name))

        ## segments
        summary.segment_results_with(category: category.name, validation: true).each do |seg_item|
          segment = seg_item[:segment].to_segment

          starting_time = summary.starting_time(category.name, segment.name) || raise
          update_performed_segment(competition, category, segment, seg_item[:panel_url],
                                   starting_time: starting_time)
          update_segment_results(competition, category, segment, seg_item[:result_url])
          update_scores(competition, category, segment, seg_item[:score_url])
        end
      end

      ## judge details
      ###        it was random order before 2016-17
      if options[:enable_judge_details] && SkateSeason.new(competition.season).between?('2016-17', nil)
        debug('update judge details and deviations', indent: 3)
        competition.scores.each do |score|
          update_judge_details(score)
          update_deviations(score)
        end
      end
      competition        ## ensure to return competition object
    end ## transaction
  end

  ################
  def parser(key, parser_type: nil)
    model = "CompetitionParser::#{key.to_s.camelize}Parser".constantize
    model = model.incorporate(parser_type) if key == :summary
    model.new(verbose: verbose)
  end
end
