class CompetitionUpdater < Updater
  using StringToModel
=begin
  include CompetitionUpdater::Deviations
  include CompetitionUpdater::Results
  include CompetitionUpdater::Scores
=end
  include CompetitionUpdater::Utils

  def clear_existing_competitions(site_url)
    ActiveRecord::Base.transaction do
      Competition.where(site_url: site_url).map(&:destroy)
    end
  end

=begin
  def update_panel(name: , nation:)
    name = normalize_persons_name(name)
    Panel.find_or_create_by(name: name).tap do |panel|
      if (nation != 'ISU') && panel.nation.blank?
        debug("... nation updated: #{nation} for #{name}", indent: 5)
        panel.update(nation: nation)
      end
    end
  end
=end
  ################
  def update_competition(site_url, opts = {})
    debug("update competition with site_url of: #{site_url}")
    default_options = { date_format: nil, force: nil, categories: nil,
                        season_from: nil, season_to: nil, params: {} }
    options = default_options.merge(opts)
    categories_to_update = (options[:categories].nil?) ? Category.all.map(&:name)  : options[:categories]
    if (!options[:force]) && (comps = Competition.where(site_url: site_url).presence)
      debug("  .. skip: already existing: #{site_url}")
      return comps.first
    end
    
    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)
      parser = CompetitionParser.new
      data = parser.parse(site_url)

      ## TODO: check season

      competition = Competition.create! do |comp|
        comp.attributes ={
          start_date: data[:time_schedule].map {|d| d[:starting_time]}.min.to_date,
          end_date: data[:time_schedule].map {|d| d[:starting_time]}.max.to_date,
        }.merge(data.slice(:site_url, :name, :country, :city))
      end
      debug('*' * 100)
      debug('%<name>s [%<short_name>s] (%<site_url>s)' % competition.attributes.symbolize_keys)

      ## category results
      data[:category_results].select{|d| categories_to_update.include?(d[:category])}.each do |item|
        competition.category_results.create! do |category_result|
          category_result.update_common_attributes(item)
          category_result.skater = find_or_create_skater(*item.values_at(:isu_number, :skater_name, :skater_nation), item[:category].to_category)
          category_result.category = item[:category].to_category

          cr_refs[item[:category]]["short"][category_result.short_ranking] = category_result
          cr_refs[item[:category]]["free"][category_result.free_ranking] = category_result
          debug(category_result.summary)
        end
      end
      ## performed segments / officials / panels
      data[:time_schedule].select{|d| categories_to_update.include?(d[:category])}.each do |item|
        competition.performed_segments.create! do |ps|
          ps.update_common_attributes(item)
          ps.category = item[:category].to_category
          ps.segment = item[:segment].to_segment
          ## officials
          officials = data[:officials]
                      .select {|d| d[:category] == item[:category] && d[:segment] == item[:segment]}
                      .reject {|d| d[:panel_name] == '-' }.each do |item|
            #panel = update_panel(name: item[:name], nation: item[:nation])
            panel = Panel.find_or_create_by(name: item[:panel_name]) {|pnl| pnl.nation = item[:panel_nation]} ## TODO: ISU
            official = ps.officials.create!(number: item[:number], panel: panel)
          end
        end
      end
      ## scores
      data[:scores].select{|d| categories_to_update.include?(d[:category])}.each do |item|
        sc = competition.scores.create! do |score|
          score.update_common_attributes(item)
          score.category = item[:category].to_category
          score.segment = item[:segment].to_segment
          ## relevant category result
          if (cr = competition.category_results.where(category: score.category, "#{score.segment.segment_type}_ranking": score.ranking).first)
            cr.update("#{score.segment.segment_type}": score)
          end
          score.skater = cr.try(:skater) ||
                         find_or_create_skater(*item.values_at(:isu_number, :skater_name, :skater_nation),
                                               item[:category].to_category)
          ## ps
          ps = competition.performed_segments.where(category: score.category, segment: score.segment).first
          score.date = ps.starting_time.to_date
          debug(score.summary)
        end
        item[:elements].each {|d| sc.elements.create!(d) }
        item[:components].each {|d| sc.components.create!(d) }
        sc.update(elements_summary: sc.elements.map(&:name).join('/'))
        sc.update(components_summary: sc.components.map(&:name).join('/'))
      end
      ## judge details and deviations
=begin      
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
=end
    end ## transaction
  end
=begin
  ################
  def parser(key, parser_type: nil)
    model = "CompetitionParser::#{key.to_s.camelize}Parser".constantize
    model = model.incorporate(parser_type) if key == :summary
    model.new(verbose: verbose)
  end
=end
end
