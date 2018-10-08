class CompetitionUpdater
  include DebugPrint
  attr_reader :parsers, :enable_judge_details

  def initialize(parser_type: nil, verbose: false, enable_judge_details: nil)
    @parser_type = parser_type
    @enable_judge_details = enable_judge_details
    @verbose = verbose
  end

  def categories_to_update(categories) ## array of strings or symbol given
    @categories_to_update ||=
      if categories.nil?
        Category.all
      else
        categories.map do |cat|
          (cat.class == String) ? Category.where(name: cat).first : cat
        end.compact
      end
  end

  def clear_existing_competitions(site_url)
    ActiveRecord::Base.transaction do
      Competition.where(site_url: site_url).map(&:destroy)
    end
  end

  def update_competition_attributes(competition, parsed, params: {})
    slice_common_attributes(competition, parsed).tap do |hash|
      competition.attributes = hash
      params.reject { |_k, _v| value.blank? }.each do |key, value|
        competition[key] = value          ## TODO: check if it works
      end
    end
    competition.country ||= CityCountry.find_by(city: competition.city).try(:country)
  end

  def summary_parser
    @summary_parser ||=
      begin
        model_class = CompetitionParser::SummaryParser
        if @parser_type
          prepended_class = "#{model_class}::#{@parser_type.to_s.camelize}".constantize
          model_class.dup.prepend(prepended_class)
        else
          model_class
        end
      end
  end

  ################
  def update_competition(site_url, *args)
    default_options = { date_format: nil, force: nil, categories: nil,
                        season_from: nil, season_to: nil, params: {} }
    options = default_options.merge(args.first || {})   ## TODO: args.first ??? wtf

    if (!options[:force]) && Competition.where(site_url: site_url).present?
      debug("  .. skip: already existing: #{site_url}")
      return
    end

    ActiveRecord::Base.transaction do
      clear_existing_competitions(site_url)
      parsed = summary_parser.parse(site_url, date_format: options[:date_format]) || (return nil)
      competition = Competition.create! do |comp|
        update_competition_attributes(comp, parsed, params: {})

        [:start_date, :end_date, :timezone].each do |key|
          comp[key] = parsed[:time_schedule].send(key)
        end
      end

      debug('*' * 100)
      debug('%<name>s [%<short_name>s] (%<site_url>s)' % competition.attributes.symbolize_keys)

      ## categories
      parsed[:category_results].each do |item|
        category = Category.find_by(name: item[:category]) || next   ## TODO: warning
        categories_to_update(options[:categories]).include?(category) || next

        update_category_results(competition, category, item[:result_url])
      end

      ## segments
      parsed[:segment_results].reject { |item| item[:result_url].blank? }.each do |item|
        category = Category.find_by(name: item[:category]) || next
        segment = Segment.find_by(name: item[:segment]) || next

        starting_time = parsed[:time_schedule]
                        .find_starting_time_by(category: item[:category], segment: item[:segment]) || raise
        update_performed_segment(competition, category, segment, item[:panel_url],
                                 starting_time: starting_time)
        update_segment_results(competition, category, segment, item[:result_url])
        update_scores(competition, category, segment, item[:score_url])
      end
      competition        ## ensure to return competition object
    end ## transaction
  end

  ################
  def update_panel(name:, nation:)
    name = normalize_persons_name(name)
    Panel.find_or_create_by(name: name).tap do |panel|
      if (nation != 'ISU') && panel.nation.blank?
        debug("... nation updated: #{nation} for #{name}", indent: 5)
        panel.update(nation: nation)
      end
    end
  end

  def update_performed_segment(competition, category, segment, panel_url, starting_time:)
    # parsed_panels = parsers[:panel].parse(panel_url)
    parsed = CompetitionParser::PanelParser.parse(panel_url)
    competition.performed_segments.create! do |ps|
      ps.update(category: category, segment: segment, starting_time: starting_time)

      ## officials
      parsed[:judges].each do |item|
        panel = update_panel(name: item[:name], nation: item[:nation])
        debug("Judge No #{item[:number]}: #{panel.name} (#{panel.nation})", indent: 5)
        ps.officials.create!(number: item[:number], panel: panel, absence: panel.name == '=')
      end
    end
  end

  ################
  def update_category_results(competition, category, result_url)
    return if result_url.blank?

    CompetitionParser::CategoryResultParser.new.parse(result_url).each do |parsed|
      ActiveRecord::Base.transaction do
        competition.category_results.create!(category: category) do |result|
          attrs = result.class.column_names.map(&:to_sym) & parsed.keys
          result.attributes = slice_common_attributes(result, parsed)
          result.update(parsed.slice(*attrs))
          result.skater = find_or_create_skater(parsed[:isu_number],
                                                parsed[:skater_name], parsed[:nation], category)
          debug(result.summary)
        end
      end
    end
  end

  ################
  def update_segment_results(competition, category, segment, result_url)
    # parsers[:segment_result].parse(result_url).tap do |items|
    CompetitionParser::SegmentResultParser.new.parse(result_url).each do |parsed|
      ActiveRecord::Base.transaction do
        relevant_cr = nil
        sc = competition.scores.create!(category: category, segment: segment) { |score|
          relevant_cr = competition.category_results
                        .where(category: category, "#{segment.segment_type}_ranking": parsed[:ranking]).first
          skater = relevant_cr.try(:skater) ||
                   find_or_create_skater(parsed[:isu_number], parsed[:skater_name], parsed[:nation], category)
          ps = competition.performed_segments
               .where(category: category, segment: segment).first || raise('no relevant Performed Segment')

          score.attributes = slice_common_attributes(score, parsed)
                             .merge(skater: skater, date: ps.starting_time.to_date)
        }
        relevant_cr.present? && relevant_cr.update(segment.segment_type => sc)
      end
    end
  end

  ################
  def update_scores(competition, category, segment, score_url)
    # parsers[:score].parse(score_url).each do |parsed|
    CompetitionParser::ScoreParser.new.parse(score_url).each do |parsed|
      ActiveRecord::Base.transaction do
        score = competition.scores
                .where(category: category, segment: segment, starting_number: parsed[:starting_number]).first ||
                raise("no relevant score found: ##{parsed[:starting_number]}")
        attrs = score.class.column_names.map(&:to_sym) & parsed.keys
        score.attributes = parsed.slice(*attrs)

        parsed[:elements].map { |item| score.elements.create!(item) }
        parsed[:components].map { |item| score.components.create!(item) }

        score.update(elements_summary: score.elements.map(&:name).join('/'))
        score.update(components_summary: score.components.map(&:value).join('/'))
        debug(score.summary)

        ## judge details
        update_judge_details(competition, category, segment, score) if @enable_judge_details
      end
    end
  end ## def

  ################
  def update_judge_details(competition, category, segment, score)
    return if competition.start_date <= Time.zone.parse('2016-7-1') # was random order in the past

    ### elements
    score.elements.each do |element|
      details = element.judges.split(/\s/).map(&:to_f)
      avg = details.sum / details.count
      ActiveRecord::Base.transaction do
        details.each.with_index(1) do |value, i|
          dev = value - avg
          official = competition.performed_segments
                     .where(category: category, segment: segment).first.officials
                     .where(number: i).first || raise("no relevant officail: #{i}")
          element.element_judge_details
            .create(number: i, value: value, official: official, average: avg, deviation: dev, abs_deviation: dev.abs)
        end
      end
    end

    ### component
    score.components.each do |component|
      details = component.judges.split(/\s/).map(&:to_f)
      avg = details.sum / details.count
      ActiveRecord::Base.transaction do
        details.each.with_index(1) do |value, i|
          dev = value - avg
          official = competition.performed_segments
                     .where(category: category, segment: segment).first.officials.where(number: i).first ||
                     raise("no relevant officail: #{i}")
          component.component_judge_details
            .create(number: i, value: value, official: official, average: avg, deviation: dev)
        end
      end
    end
  end

  ################
  ## utils
  def slice_common_attributes(model, hash)
    hash.slice(*model.class.column_names.map(&:to_sym) & hash.keys)
  end

  def find_or_create_skater(isu_number, skater_name, nation, category)
    normalized = normalize_persons_name(skater_name)
    @skater_name_correction ||= YAML.load_file(Rails.root.join('config', 'skater_name_correction.yml'))
    corrected_skater_name = @skater_name_correction[normalized] || normalized
    ActiveRecord::Base.transaction do
      Skater.find_or_create_by_isu_number_or_name(isu_number, corrected_skater_name) do |sk|
        sk.attributes = {
          category: Category.where(team: false, category_type: category.category_type).first,
          nation:   nation,
        }
      end
    end
  end

  def normalize_persons_name(name)
    if name.to_s =~ /^([A-Z\-]+) ([A-Z][A-Za-z].*)$/
      [$2, $1].join(' ')
    else
      name
    end
  end
end
