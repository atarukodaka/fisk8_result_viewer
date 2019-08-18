class CompetitionUpdater < Updater
  include NormalizePersonName
  using StringToModel

  def update_competition(site_url, options = {})
    debug('*' * 100)
    debug("updating competition '%s' with %s parser" % [site_url, options[:parser_type] || 'standard'])
    return if !options[:force] && competition_exists?(site_url)

    parser = get_parser(options[:parser_type])
    data = parser.parse(site_url, encoding: options[:encoding]) || return
    season = SkateSeason.new(data[:start_date])

    return unless season_to_update?(season, options.slice(:season, :season_from, :season_to))
    categories_to_update = options[:categories] || Category.all.map(&:name)

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)

      competition = Competition.create! do |comp|
        data[:country] ||= CityCountry.find_by(city: data[:city]).try(:country)
        comp.attributes = data.slice(:site_url, :name, :country, :city)
        comp.start_date = data[:start_date]
        comp.end_date = data[:end_date]
        comp.timezone = data[:performed_segments].first[:starting_time].time_zone.name

        yield comp if block_given?
      end

      data[:performed_categories].each do |cat_item|
        next unless categories_to_update.include?(cat_item[:category])

        category = Category.find_by(name: cat_item[:category])
        debug('===  %s ===' % [ category.name ], indent: 2)

        parser.parse_category_result(cat_item[:result_url], category.name).each do |result|
          update_category_result(competition, category, result)
        end if cat_item[:result_url]

        data[:performed_segments].select {|d| d[:category] == category.name }.each do |seg_item|
          segment = Segment.find_by(name: seg_item[:segment]) || next
          debug('===  %s ===' % [ segment.name ], indent: 2)

          ## performed segment
          performed_segment = competition.performed_segments.create! do |ps|
            ps.category = category
            ps.segment = segment
            ps.starting_time = seg_item[:starting_time]
          end

          ## officials
          officials = parser.parse_officials(seg_item[:official_url], category.name, segment.name).each do |official|
            next if official[:panel_name] == '-'

            panel = Panel.find_or_create_by(name: normalize_person_name(official[:panel_name]))
            if panel.nation.blank? &&
              official[:panel_nation].present? && (official[:panel_nation] != 'ISU')
              panel.update!(nation: official[:panel_nation])
            end
            performed_segment.officials.create!(official.slice(:function_type, :function, :number)) do |of|
              of.panel = panel
            end
          end

          ## scores
          parser.parse_score(seg_item[:score_url], category.name, segment.name).each do |item|
            score = update_score(competition, category, segment, item) do |sc|
              sc.performed_segment = performed_segment
              sc.date = performed_segment.starting_time.to_date
            end
            next if !options[:enable_judge_details] || season < '2016-17'

            ## details / deviations
            officials = score.performed_segment.officials.map { |d| [d.number, d] }.to_h
            update_judge_details(score, officials: officials)
            update_deviations(score, officials: officials)

          end
        end
      end

      #debug('%<name>s [%<short_name>s] at %<city>s/%<country>s on %<start_date>s' %
      #      competition.attributes.symbolize_keys)
      competition        ## ensure to return competition object
    end ## transaction
  end

  ################
  def update_category_result(competition, category, item)
    competition.category_results.create! do |category_result|
      category_result.update_common_attributes(item)
      category_result.skater = find_or_create_skater(item)
      category_result.category = category
      debug(category_result.summary)
    end
  end

  def update_score(competition, category, segment, item)
    cr = nil
    sc = competition.scores.create! do |score|
      score.update_common_attributes(item)
      score.category = category
      score.segment = segment

      ## relevant category result
      cr = competition.category_results.category(category)
           .segment_ranking(segment, score.ranking).first
      score.skater = cr.try(:skater) || find_or_create_skater(item)

      yield score if block_given?
      debug(score.summary)
    end
    cr&.update(segment.segment_type => sc)

    ## details
    elements_summary = item[:elements].map { |d| sc.elements.create!(d); d[:name] }.join('/')
    components_summary = item[:components].map { |d| sc.components.create!(d); d[:value] }.join('/')

    sc.update(elements_summary: elements_summary)
    sc.update(components_summary: components_summary)

    sc  ## ensure to return score object
  end

  def update_judge_details(score, officials:)
    [score.elements, score.components].flatten.each do |detailable|
      details = detailable.judges.split(/\s/).map(&:to_f)
      average = details.sum / details.size
      detailable.update(average: average)

      details.each.with_index(1) do |value, i|
        JudgeDetail.create(detailable: detailable, number: i, value: value,
                           official: officials[i], deviation: average - value)
      end
    end
  end

  def update_deviations(score, officials:)
    num_elements = score.elements.count
    ActiveRecord::Base.transaction do
      officials.values.each do |official|
        tes_dev = JudgeDetail.where(official: official, "elements.score_id": score.id)
                  .joins(:element).pluck(:deviation).map(&:abs).sum
        pcs_dev = JudgeDetail.where(official: official, "components.score_id": score.id)
                  .joins(:component).sum(:deviation)

        score.deviations.create!(official: official,
                                tes_deviation: tes_dev,
                                tes_deviation_ratio: tes_dev / num_elements,
                                pcs_deviation: pcs_dev,
                                pcs_deviation_ratio: pcs_dev / 7.5)
      end
    end
  end

  ################
  ## utils
  def competition_exists?(site_url)
    if Competition.find_by(site_url: site_url)
      debug('already existing', indent: 3)
      true
    else
      false
    end
  end

  def clear_existing_competitions(site_url)
    ActiveRecord::Base.transaction do
      Competition.where(site_url: site_url).map(&:destroy)
    end
  end

  def get_parser(parser_type = nil)
    if parser_type.present?
      "CompetitionParser::Extension::#{parser_type.to_s.camelize}".constantize
    else
      CompetitionParser
    end.new(verbose: verbose)
  end
  def season_to_update?(this_season, season_options)
    season = season_options[:season]
    from = (season) ? season : season_options[:season_from]
    to = (season) ? season : season_options[:season_to]

    return true if this_season.between?(from, to)

    debug('skipping...season %s out of range [%s, %s]' % [this_season, from, to], indent: 3)
    false
  end
end
