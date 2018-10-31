class CompetitionUpdater < Updater
  include NormalizePersonName
  using CategorySegmentSelector
  using StringToModel
  using MapValue

  ################
  def update_competition(site_url, options = {})
    debug('*' * 100)
    debug("updating competition '%s' with %s parser" % [site_url, options[:parser_type] || 'standard'])
    return if !options[:force] && competition_exists?(site_url)

    data = parser(options[:parser_type])
           .parse(site_url, options.slice(:date_format, :categories, :season_from, :season_to)) || return

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)

      competition = Competition.create! do |comp|
        comp.attributes = {
          start_date: data[:time_schedule].map_value(:starting_time).min.to_date,
          end_date: data[:time_schedule].map_value(:starting_time).max.to_date,
          timezone: timezone(data),
        }
        comp.attributes = data.slice(:site_url, :name, :country, :city)
        yield comp if block_given?
      end

      debug('%<name>s [%<short_name>s] at %<city>s/%<country>s on %<start_date>s' %
            competition.attributes.symbolize_keys)
      season = SkateSeason.new(competition.season)
      ## each categories
      data[:scores].categories.each do |category|
        debug('===  %s (%s) ===' % [category.name, competition.short_name], indent: 2)
        data[:category_results].select_category(category).each do |item|
          update_category_result(competition, category, item)
        end
        ## each segments
        data[:scores].select_category(category).segments.each do |segment|
          update_segment(competition, category, segment, time_schedule: data[:time_schedule],
                         officials: data[:officials])
          ## scores
          data[:scores].select_category_segment(category, segment).each do |item|
            score = update_score(competition, category, segment, item)
            next if !options[:enable_judge_details] || season < '2016-17'

            ## details / deviations
            officials = score.performed_segment.officials.map { |d| [d.number, d] }.to_h
            update_judge_details(score, officials: officials)
            update_deviations(score, officials: officials)
          end
        end
      end
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

  def update_segment(competition, category, segment, time_schedule:, officials:)
    ## performed_segments
    performed_segment = competition.performed_segments.create! do |ps|
      item = time_schedule.select_category_segment(category, segment).first
      ps.update_common_attributes(item)
      ps.category = category
      ps.segment = segment
    end

    ## officials
    officials.select_category_segment(category, segment).each do |official|
      next if official[:panel_name] == '-'

      panel = Panel.find_or_create_by(name: normalize_person_name(official[:panel_name]))
      panel.update!(nation: official[:panel_nation]) if official[:panel_nation] != 'ISU' && panel.nation.blank?
      performed_segment.officials.create!(number: official[:number], panel: panel)
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

      ## performed segments
      ps = competition.performed_segments.category(category).segment(segment).first
      score.date = ps.starting_time.to_date
      score.performed_segment = ps
      debug(score.summary)
    end
    cr&.update(segment.segment_type => sc)

    ## details
    elements_summary = item[:elements].map { |d| sc.elements.create!(d); d[:name] }.join('(/')
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
    #officials = score.performed_segment.officials.map { |d| [d.number, d] }.to_h
    #officials = JudgeDetail.where("elements.score_id": score.id)
    #officials = score.elements.first.officials
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

  def parser(parser_type = nil)
    if parser_type.present?
      "CompetitionParser::Extension::#{parser_type.to_s.camelize}".constantize
    else
      CompetitionParser
    end.new(verbose: verbose)
  end

  def timezone(data)
    schedule = data[:time_schedule].first || (return 'UTC')
    schedule[:starting_time].time_zone.name
  end

  def find_or_create_skater(item)
    corrected_skater_name = SkaterNameCorrection.correct(item[:skater_name])
    skater = (Skater.find_by(isu_number: item[:isu_number]) if item[:isu_number].present?) ||
             Skater.find_by(name: corrected_skater_name)

    skater || Skater.create! do |sk|
      category_type = item[:category].to_category.category_type
      sk.attributes = {
        isu_number: item[:isu_number],
        name: corrected_skater_name,
        nation: item[:skater_nation],
        category_type: category_type,
      }
    end
  end
end
