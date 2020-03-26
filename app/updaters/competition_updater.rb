class CompetitionUpdater < Updater
  include NormalizePersonName
  using StringToModel

  def update_competition(site_url, options = {})
    debug('*' * 100)
    debug("updating competition '%s' with %s parser" % [site_url, options[:parser_type] || 'standard'])
    return if !options[:force] && competition_exists?(site_url)

    parser = get_parser(options[:parser_type])
    data = parser.parse_summary(site_url, encoding: options[:encoding]) || return
    category_skipper = CategorySkipper.new(options[:categories], excluding: options[:excluding_categories])
    season_skipper = SeasonSkipper.new(options[:season], from: options[:season_from], to: options[:season_to])
    season = SkateSeason.new(data[:start_date])
    return if season_skipper.skip?(season)

    data.merge!(options[:attributes] || {})
    normalize(data)

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)

      competition = Competition.create! do |comp|
        data[:country] ||= CityCountry.find_by(city: data[:city]).try(:country)
        #        comp.attributes = data.merge(options[:attributes] || {}).slice(:start_date, :end_date, :timezone, :site_url, :name, :short_name, :country, :city, :competition_class, :competition_type).compact
        comp.attributes = data.slice(:start_date, :end_date, :timezone, :site_url, :name, :short_name, :country, :city, :competition_class, :competition_type).compact
        comp.season = season
        yield comp if block_given?
      end

      ## category
      data[:summary_table].map { |d| d[:category] }.uniq.each do |cat|
        next if category_skipper.skip?(cat)

        category = Category.find_by(name: cat) || next

        ## category result
        data[:summary_table].find { |d| d[:type] == :category && d[:category] == cat }.tap { |d|
          next if d.nil? || d[:result_url].nil?

          parser.parse_category_result(d[:result_url], cat).each do |item|
            update_category_result(competition, category, item)
          end
        }
        ## segments
        data[:summary_table].select { |d| d[:type] == :segment && d[:category] == cat }.each do |d|
          segment = Segment.find_by(name: d[:segment]) || next
          ## official
          parser.parse_officials(d[:official_url], d[:category], d[:segment]).each do |item|
            update_official(competition, category, segment, item)
          end

          ## segment results
          starting_time = data[:time_schedule].first { |s| s[:category] == category.name && s[:segment] == segment.name }.try(:[], :starting_time)
          competition.time_schedules.create!(category: category, segment: segment,
            starting_time: starting_time)
          date = starting_time.to_date

          segment_results = parser.parse_segment_result(d[:result_url], d[:category], d[:segment])
          scores = parser.parse_score(d[:score_url], d[:category], d[:segment])

          segment_results.each do |res|
            score = scores.find { |s| s[:ranking] == res[:ranking] } || next
            validate_score_matching(res, score)
            segment_result = update_segment_result(competition, category, segment, res)
            score[:elements].each { |d| segment_result.elements.create!(d) }
            score[:components].each { |d| segment_result.components.create!(d) }

            segment_result.date = date
            segment_result.elements_summary = score[:elements].map { |d| d[:name] }.join('/')
            segment_result.components_summary = score[:components].map { |d| d[:value] }.join('/')
            segment_result.save!
            next if !options[:enable_judge_details] || competition.season < '2016-17'

            ## details / deviations
            officials = competition.officials.where(category: category, segment: segment).map { |d| [d.number, d] }.to_h
            update_judge_details(segment_result, officials: officials)
            update_deviations(segment_result, officials: officials)
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
      category_result.skater = Skater.find_or_create_by_name_or_isu_number(name: item[:skater_name], isu_number: item[:isu_number]) do |sk|
        sk.nation = item[:skater_nation]
        sk.category_type = category.category_type
      end
      category_result.category = category
      debug(category_result.summary)
    end
  end

  def update_official(competition, category, segment, official)
    return if official[:panel_name] == '-'

    panel = Panel.find_or_create_by(name: normalize_person_name(official[:panel_name]))
    if panel.nation.blank? &&
       official[:panel_nation].present? && (official[:panel_nation] != 'ISU')
      panel.update!(nation: official[:panel_nation])
    end
    Official.create!(competition: competition, category: category, segment: segment) do |of|
      of.attributes = official.slice(:function_type, :function, :number)
      of.panel = panel
    end
  end

  def update_segment_result(competition, category, segment, item)
    cr = nil
    sc = competition.scores.create! do |score|
      score.update_common_attributes(item)
      score.category = category
      score.segment = segment

      ## relevant category result
      cr = competition.category_results.category(category).segment_ranking(segment, score.ranking).first
      score.skater = cr.try(:skater) || Skater.find_or_create_by_name_or_isu_number(name: item[:skater_name], isu_number: item[:isu_number]) do |sk|
        sk.nation = item[:skater_nation]
        sk.category_type = category.category_type
      end

      yield score if block_given?
      debug(score.summary)
    end
    if cr
      cr.update(segment.segment_type => sc)
      [:tss, :tes, :pcs, :deductions].each do |key|
        cr.update("#{segment.segment_type}_#{key}" => sc[key])
      end
    end

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

  def normalize(data)
    CompetitionNormalize.all.each do |item|
      next unless data[:short_name].try(:match?, item.regex)

      data[:competition_class] = item.competition_class
      data[:competition_type] = item.competition_type
      if item.name
        hash = { year: data[:start_date].year, country: data[:country], city: data[:city] }
        data[:name] = item.name % hash
      end
    end
  end

  def validate_score_matching(segment_result, score)
    [:skater_nation, :ranking, :tss, :tes, :pcs, :deduction, :category, :segment].each do |key|
      if segment_result[key] != score[key]
        debug("invalid data for key '#{key}': '#{segment_result[key]}' doesnt match '#{score[key]}'")
      end
    end
  end

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
end
