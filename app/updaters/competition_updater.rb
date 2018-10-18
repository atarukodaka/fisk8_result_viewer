class CompetitionUpdater < Updater
  module CategorySegmentSelector
    refine Array do
      using StringToModel
      def categories
        map { |d| d[:category] }.uniq.map(&:to_category)
      end

      def segments
        map { |d| d[:segment] }.uniq.map(&:to_segment)
      end

      def select_category(category)
        select { |d| d[:category] == category.name }
      end

      def select_category_segment(category, segment)
        select { |d| d[:category] == category.name && d[:segment] == segment.name }
      end
    end
  end
  ################
  using CategorySegmentSelector
  using StringToModel
  include CompetitionUpdater::Deviations

  def clear_existing_competitions(site_url)
    ActiveRecord::Base.transaction do
      Competition.where(site_url: site_url).map(&:destroy)
    end
  end

  def categories_to_parse(cats)
    (cats.nil?) ? Category.all.map(&:name) : Category.all.map(&:name) & cats
  end

  def parser(parser_type = nil)
    if parser_type.present?
      "CompetitionParser::Extension::#{parser_type.to_s.camelize}".constantize
    else
      CompetitionParser
    end.new(verbose: verbose)
  end

  ################
  def update_competition(site_url, opts = {})
    debug('*' * 100)
    debug("updating competition '%s' with %s parser" %
          [site_url, opts[:parser_type] || 'normal'])
    default_options = { parser_type: nil, date_format: nil, force: nil, categories: nil,
                        season_from: nil, season_to: nil }
    options = default_options.merge(opts)
    if (!options[:force]) && (competition = Competition.find_by(site_url: site_url))
      debug('  .. skip: already existing')
      return competition
    end
    data = parser(options[:parser_type])
           .parse(site_url, date_format: options[:date_format],
                  categories: categories_to_parse(options[:categories]),
                  season_from: options[:season_from], season_to: options[:season_to]) || return

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)

      competition = Competition.create! do |comp|
        comp.attributes = {
          start_date: data[:time_schedule].map { |d| d[:starting_time] }.min.to_date,
          end_date: data[:time_schedule].map { |d| d[:starting_time] }.max.to_date,
        }.merge(data.slice(:site_url, :name, :country, :city))
        yield comp if block_given?
      end

      msg = '%<name>s [%<short_name>s] at %<city>s/%<country>s on %<start_date>s'
      debug(msg % competition.attributes.symbolize_keys)

      ## each catgories
      data[:scores].categories.each do |category|
        debug('===  %s (%s) ===' % [category.name, competition.short_name], indent: 2)

        ## category results
        data[:category_results].select_category(category).each do |item|
          competition.category_results.create! do |category_result|
            category_result.update_common_attributes(item)
            category_result.attributes = {
              skater: find_or_create_skater(item),
              category: category,
            }
            debug(category_result.summary)
          end
        end

        ## each segments
        data[:scores].select_category(category).segments.each do |segment|
          ## performed_segments
          performed_segment = competition.performed_segments.create! do |ps|
            item = data[:time_schedule].select_category_segment(category, segment).first
            ps.update_common_attributes(item)
            ps.category = category
            ps.segment = segment
          end

          ## officials
          data[:officials].select_category_segment(category, segment)
            .reject { |d| d[:panel_name] == '-' }.each do |official|
            panel = Panel.find_or_create_by(name: official[:panel_name])
            panel.update!(nation: official[:panel_nation]) if official[:panel_nation] != 'ISU' && panel.nation.blank?
            performed_segment.officials.create!(number: official[:number], panel: panel)
          end

          ## scores
          data[:scores].select_category_segment(category, segment).each do |item|
            update_score(competition, item)
          end
        end
      end
      ## judge details and deviations
      update_details(competition) if options[:enable_judge_details]
      competition        ## ensure to return competition object
    end ## transaction
  end

  def update_score(competition, item)
    category = item[:category].to_category
    segment = item[:segment].to_segment
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
      debug(score.summary)
    end
    cr&.update(segment.segment_type => sc)

    item[:elements].each { |d| sc.elements.create!(d) }
    item[:components].each { |d| sc.components.create!(d) }
    sc.update(elements_summary: sc.elements.map(&:name).join('/'))
    sc.update(components_summary: sc.components.map(&:name).join('/'))
  end

  def update_details(competition)
    ## it was random order before 2016-17
    return unless SkateSeason.new(competition.season).between?('2016-17', nil)

    debug('update judge details and deviations', indent: 3)
    competition.scores.each do |score|
      update_judge_details(score)
      update_deviations(score)
    end
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

  ################
  ## utils
  def find_or_create_skater(item)
    corrected_skater_name = SkaterNameCorrection.correct(item[:skater_name])
    skater = (Skater.find_by(isu_number: item[:isu_number]) if item[:isu_number].present?) ||
             Skater.find_by(name: item[:name])

    skater || Skater.create! do |sk|
      category_type = item[:category].to_category.category_type
      sk.attributes = {
        isu_number: item[:isu_number],
        name: corrected_skater_name,
        nation: item[:nation],
        category_type: category_type,
      }
    end
  end
end
