class CompetitionUpdater < Updater
  using StringToModel
  include CompetitionUpdater::Utils
  include CompetitionUpdater::Deviations

  def clear_existing_competitions(site_url)
    ActiveRecord::Base.transaction do
      Competition.where(site_url: site_url).map(&:destroy)
    end
  end

  def categories_to_parse(cats)
    if cats.nil?
      Category.all.map(&:name)
    else
      Category.all.map(&:name) & cats
    end
  end

  def parser(parser_type = nil)
    model = (parser_type) ? ['CompetitionParser', 'Extension', parser_type.to_s.camelize].join('::').constantize : CompetitionParser
    model.new(verbose: verbose)
  end
  ################
  def update_competition(site_url, opts = {})
    debug("update competition with site_url of: #{site_url}")
    default_options = { parser_type: nil, date_format: nil, force: nil, categories: nil,
                        season_from: nil, season_to: nil, params: {} }
    options = default_options.merge(opts)
    if (!options[:force]) && (comps = Competition.where(site_url: site_url).presence)
      debug("  .. skip: already existing: #{site_url}")
      return comps.first
    end
    data = parser(options[:parser_type])
           .parse(site_url, date_format: options[:date_format],
                  categories: categories_to_parse(options[:categories]),
                  season_from: options[:season_from], season_to: options[:season_to]) || return
    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)

      ## TODO: check season

      competition = Competition.create! do |comp|
        comp.attributes ={
          start_date: data[:time_schedule].map {|d| d[:starting_time]}.min.to_date,
          end_date: data[:time_schedule].map {|d| d[:starting_time]}.max.to_date,
        }.merge(data.slice(:site_url, :name, :country, :city))
      end
      debug('*' * 100)
      debug('%<name>s [%<short_name>s] (%<site_url>s)' % competition.attributes.symbolize_keys)

      data[:scores].map {|d| d[:category]}.uniq.map(&:to_category).each do |category|
        debug("===  %s (%s) ===" % [category.name, competition.short_name], indent: 2)
        ## category results
        data[:category_results].select{|d| d[:category] == category.name }.each do |item|
          competition.category_results.create! do |category_result|
            category_result.update_common_attributes(item)
            category_result.skater = find_or_create_skater(*item.values_at(:isu_number, :skater_name, :skater_nation), item[:category].to_category)
            category_result.category = item[:category].to_category
            debug(category_result.summary)
          end
        end
        ## performed segments / officials / panels
        data[:time_schedule].select {|d| d[:category] == category.name }.each do |item|
          performed_segment = competition.performed_segments.create! do |ps|
            ps.update_common_attributes(item)
            ps.category = item[:category].to_category
            ps.segment = item[:segment].to_segment
          end
          ## officials
          officials = data[:officials]
                      .select {|d| d[:category] == item[:category] && d[:segment] == item[:segment]}
                      .reject {|d| d[:panel_name] == '-' }.each do |item|
            panel = Panel.find_or_create_by(name: item[:panel_name]) {|pnl| pnl.nation = item[:panel_nation]} ## TODO: ISU
            official = performed_segment.officials.create!(number: item[:number], panel: panel)
          end
        end
        ## scores
        data[:scores].select {|d| d[:category] == category.name }.each do |item|
          cr = nil
          sc = competition.scores.create! do |score|
            score.update_common_attributes(item)
            score.category = item[:category].to_category
            score.segment = item[:segment].to_segment
            ## relevant category result
            cr = competition.category_results.where(category: score.category, "#{score.segment.segment_type}_ranking": score.ranking).first
            score.skater = cr.try(:skater) ||
                           find_or_create_skater(*item.values_at(:isu_number, :skater_name, :skater_nation),
                                                 item[:category].to_category)
            ## ps
            ps = competition.performed_segments.where(category: score.category, segment: score.segment).first
            score.date = ps.starting_time.to_date
            debug(score.summary)          
          end
          cr.update(sc.segment.segment_type => sc) if cr

          item[:elements].each {|d| sc.elements.create!(d) }
          item[:components].each {|d| sc.components.create!(d) }
          sc.update(elements_summary: sc.elements.map(&:name).join('/'))
          sc.update(components_summary: sc.components.map(&:name).join('/'))
        end
      end
      ## judge details and deviations
      ###        it was random order before 2016-17
      if options[:enable_judge_details] && SkateSeason.new(competition.season).between?('2016-17', nil)
        debug('update judge details and deviations', indent: 3)
        competition.scores.each do |score|
          update_judge_details(score)
          update_deviations(score)
        end
      end
      competition        ## ensure to return competition object
=begin      
      summary = parser(:summary, parser_type: options[:parser_type])
                .parse(site_url, date_format: options[:date_format]) || return
      summary.season.between?(options[:season_from], options[:season_to]) ||
        begin
          debug('skip: season out of range ')
          return
        end
=end
    end ## transaction
  end
  ################
  def update_judge_details(score)
    officials = score.performed_segment.officials.map { |d| [d.number, d] }.to_h

    score.elements.each do |element|
      element.judges.split(/\s/).map(&:to_f).each.with_index(1) do |value, i|
        element.element_judge_details.create(number: i, value: value, official: officials[i])
      end
    end
    score.components.each do |component|
      component.judges.split(/\s/).map(&:to_f).each.with_index(1) do |value, i|
        component.component_judge_details.create(number: i, value: value, official: officials[i])
      end
    end
  end
  
end
