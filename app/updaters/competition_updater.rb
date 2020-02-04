class CategorySkipper
  def initialize(categories, excluding: nil)
    excluding_categories ||= []
    @categories_to_update = categories || Category.all.map(&:name).reject {|d| Array(excluding).include?(d) }
  end

  def skip?(category)
    !@categories_to_update.include?(category)
  end
end


class CompetitionUpdater < Updater
  include NormalizePersonName
  using StringToModel

  def update_competition(site_url, options = {})
    debug('*' * 100)
    debug("updating competition '%s' with %s parser" % [site_url, options[:parser_type] || 'standard'])
    return if !options[:force] && competition_exists?(site_url)

    #categories_to_update = options[:categories] || Category.all.map(&:name).reject {|d| Array(options[:excluding_categories]).include?(d) }

    parser = get_parser(options[:parser_type])

    skippers = {
      category: CategorySkipper.new(options[:categories], excluding: options[:excluding_categories]),
      season: SeasonSkipper.new(options[:season], from: options[:season_from], to: options[:season_to]),
    }

    data = parser.parse(site_url, encoding: options[:encoding], season_skipper: skippers[:season], category_skipper: skippers[:category]) || return

#    data = parser.parse(site_url, encoding: options[:encoding], categories: categories_to_update, season_skipper: SeasonSkipper.new(options[:season], options[:season_from], options[:season_to])) || return

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)

      competition = Competition.create! do |comp|
        data[:country] ||= CityCountry.find_by(city: data[:city]).try(:country)
        comp.attributes = data.slice(:site_url, :name, :country, :city, :start_date, :end_date, :timezone)

        yield comp if block_given?
      end

      ## time schedule
      data[:time_schedule].each do |item|
        #next unless categories_to_update.include?(item[:category])
        #next if skippers[:category].skip?(item[:category])
        category = item[:category].to_category || next
        segment = item[:segment].to_segment || next
        competition.time_schedules.create!(category: category, segment: segment,
          starting_time: item[:starting_time])
      end
      competition.season = SkateSeason.new(data[:start_date])

      ## category result
      data[:category_results].each do |item|
        category = Category.find_by(name: item[:category]) || next
        update_category_result(competition, category, item)
      end
      ## officials
      data[:officials].each do |item|
        category = Category.find_by(name: item[:category]) || next
        segment = Segment.find_by(name: item[:segment]) || next
        update_official(competition, category, segment, item)
      end

      ## segment results
      #   get skater and points details from segment results table
      #   get elements, components details from score pdf sheets
      data[:segment_results].each do |item|
        category = Category.find_by(name: item[:category]) || next
        segment = Segment.find_by(name: item[:segment]) || next
        segment_result = update_segment_result(competition, category, segment, item)
        segment_result.date = data[:time_schedule].select {|d| d[:category] == category.name && d[:segment] == segment.name }.first.try(:[], :starting_time)

        score = data[:scores].select {|d| d[:ranking] == item[:ranking] && d[:category] == item[:category] && d[:segment] == item[:segment] }.first || next

        ## check if segment results data matches score data
        [:skater_nation, :ranking, :tss, :tes, :pcs, :deduction, :category, :segment].each do |key|
          if item[key] != score[key]
            debug("invalid data for key '#{key}': '#{item[key]}' doesnt match '#{score[key]}'")
          end
        end
        score[:elements].each { |d| segment_result.elements.create!(d) }
        score[:components].each { |d| segment_result.components.create!(d) }

        segment_result.elements_summary = score[:elements].map {|d| d[:name]}.join('/')
        segment_result.components_summary = score[:components].map {|d| d[:value]}.join('/')
        segment_result.save!
        next if !options[:enable_judge_details] || competition.season < '2016-17'

        ## details / deviations
        officials = competition.officials.where(category: category, segment: segment).map {|d| [d.number, d] }.to_h
        update_judge_details(segment_result, officials: officials)
        update_deviations(segment_result, officials: officials)
      end

      competition        ## ensure to return competition object
    end ## transaction
  end

  ################
  def update_category_result(competition, category, item)
    competition.category_results.create! do |category_result|
      category_result.update_common_attributes(item)
      #category_result.skater = find_or_create_skater(item.slice(:skater_name, :isu_number, #:skater_nation, :category))
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
=begin
  def season_to_update?(this_season, season_options)
    season = season_options[:season]
    from = (season) ? season : season_options[:season_from]
    to = (season) ? season : season_options[:season_to]

    return true if this_season.between?(from, to)

    debug('skipping...season %s out of range [%s, %s]' % [this_season, from, to], indent: 3)
    false
  end
=end
end
