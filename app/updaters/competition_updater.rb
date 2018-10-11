class CompetitionUpdater < Updater
  using StringToModel
  attr_reader :parsers

  def initialize(parser_type: nil, verbose: false)
    @parser_type = parser_type
    super(verbose: verbose)
  end

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
      competition[key] =  summary[:time_schedule].send(key)
    end
  end

  def summary_parser
    @summary_parser ||=
      begin
        # model_class.incorporate(@parser_type)
        model_class = CompetitionParser::SummaryParser

        if @parser_type
          prepended_class = "#{model_class}::Extension::#{@parser_type.to_s.camelize}".constantize
          model_class.dup.prepend(prepended_class)
        else
          model_class
        end
      end.new(verbose: @verbose)
  end

  def parser(key)
    case key
    when :summary
      sumary_parser
    when :category_result, :segment_result, :score, :panel
      "CompetitionParser::#{key.to_s.camelize}Parser".constantize.new(verbose: @verbose)
    end
  end
  
  def categories_to_update(categories1, categories2)
    return categories2.map(&:to_category)  if categories1.nil?
    
    (Array(categories1) & Array(categories2)).map(&:to_category)
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
      summary = summary_parser.parse(site_url, date_format: options[:date_format]) || return
      return unless summary[:time_schedule].season.between?(options[:season_from], options[:season_to])

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

          starting_time = summary[:time_schedule].starting_time(category.name, segment.name) || raise
          update_performed_segment(competition, category, segment, seg_item[:panel_url],
                                   starting_time: starting_time)
          update_segment_results(competition, category, segment, seg_item[:result_url])
          update_scores(competition, category, segment, seg_item[:score_url],
                        enable_judge_details: options[:enable_judge_details])
        end
      end

      ## judge details
      # was random order in the past
      if options[:enable_judge_details] && competition.start_date > Time.zone.parse('2016-7-1')
        competition.scores.each do |score|
          update_judge_details(score)
        end
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
    # parsed = CompetitionParser::PanelParser.parse(panel_url)
    parsed = parser(:panel).parse(panel_url)
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

    # CompetitionParser::CategoryResultParser.new.parse(result_url).each do |parsed|
    parser(:category_result).parse(result_url).each do |parsed|
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
    # CompetitionParser::SegmentResultParser.new.parse(result_url).each do |parsed|
    parser(:segment_result).parse(result_url).each do |parsed|
      ActiveRecord::Base.transaction do
        update_score(competition, category, segment, attributes: parsed)
      end
    end
  end

  def update_score(competition, category, segment, attributes: {})
    relevant_cr = nil
    ActiveRecord::Base.transaction do
      sc = competition.scores.create!(category: category, segment: segment) { |score|
        relevant_cr = competition.category_results
                      .where(category: category, "#{segment.segment_type}_ranking": attributes[:ranking]).first
        skater = relevant_cr.try(:skater) ||
                 find_or_create_skater(attributes[:isu_number], attributes[:skater_name], attributes[:nation], category)
        ps = competition.performed_segments
             .where(category: category, segment: segment).first || raise('no relevant Performed Segment')

        score.attributes = slice_common_attributes(score, attributes)
                           .merge(skater: skater, date: ps.starting_time.to_date)
      }
      relevant_cr.present? && relevant_cr.update(segment.segment_type => sc)
      sc            ## ensure to return score object
    end
  end

  ################
  def update_scores(competition, category, segment, score_url, enable_judge_details: false)
    parser(:score).parse(score_url).each do |attrs|
      ActiveRecord::Base.transaction do
        score = competition.scores
                .where(category: category, segment: segment, starting_number: attrs[:starting_number]).first ||
                begin
                  detail = "#{category.name}/#{segment.name}##{attrs[:starting_number]}"
                  debug("no relevant score found: #{detail}", indent: 10)
                  update_score(competition, category, segment, attributes: attrs)
                end

        score.attributes = slice_common_attributes(score, attrs)

        attrs[:elements].map { |item| score.elements.create!(item) }
        attrs[:components].map { |item| score.components.create!(item) }

        score.update(elements_summary: score.elements.map(&:name).join('/'))
        score.update(components_summary: score.components.map(&:value).join('/'))
        debug(score.summary)

        ## judge details
        #update_judge_details(competition, category, segment, score) if enable_judge_details
      end
    end
  end ## def

  ################
  def update_judge_details(score)
    officials = score.performed_segment.officials.map{|d| [d.number, d]}.to_h

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
    
=begin
    ### elements
    score.elements.each do |element|
      details = element.judges.split(/\s/).map(&:to_f)
      avg = details.sum / details.count
      ActiveRecord::Base.transaction do
        details.each.with_index(1) do |value, i|
          dev = value - avg
          official = score.competition.performed_segments
                     .where(category: score.category, segment: score.segment).first.officials
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
          official = score.competition.performed_segments
                     .where(category: score.category, segment: score.segment).first.officials
                     .where(number: i).first ||
                     raise("no relevant officail: #{i}")
          component.component_judge_details
            .create(number: i, value: value, official: official, average: avg, deviation: dev)
        end
      end
    end
=end
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
