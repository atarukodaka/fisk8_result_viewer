class CompetitionUpdater
  include DebugPrint
  attr_reader :parsers, :enable_judge_details

  def initialize(parser_type: nil, verbose: false, enable_judge_details: nil)
    @parsers = CompetitionParser::ParserBuilder.build(parser_type, verbose: verbose)
    @enable_judge_details = enable_judge_details
    @verbose = verbose
  end

  def within_season?(season, from: nil, to: nil)
    return true if from.nil? || to.nil?

    this_season = SkateSeason.new(season)

    if (!from.nil?) && (!to.nil?)
      this_season.between?(from, to)
    elsif (!from.nil?) && to.nil?
      this_season >= SkateSeason.new(from)
    elsif (from.nil?) && (!to.nil?)
      this_season <= SkateSeason.new(to)
    end
  end

  def get_categories_to_update(categories) ## array of strings or symbol given
    if categories.nil?
      Category.all
    else
      categories.map do |cat|
        (cat.class == String) ? Category.where(name: cat).first : cat
      end.compact
    end
  end

  ################
  def update_competition(site_url, *args)
    default_options = { date_format: nil, force: nil, categories: nil,
                        season_from: nil, season_to: nil, params: {} }
    options = default_options.merge(args.first || {})
    categories_to_update = get_categories_to_update(options[:categories])

    ActiveRecord::Base.transaction do
      ## existing check
      if (competitions = Competition.where(site_url: site_url).presence)
        if options[:force]
          competitions.map(&:destroy)
        else
          debug("skip: '#{site_url}' already exists", indent: 5)
          return nil
        end
      end

      parsed = parsers[:summary].parse(site_url, date_format: options[:date_format]).presence ||
               (return nil)
      ## check season from/to
=begin
      unless within_season?(parsed[:season], from: options[:season_from], to: options[:season_to])
        debug('skip: not within specific season', indent: 5)
        return
      end
=end
      Competition.create! do |competition|
        slice_common_attributes(competition, parsed).tap do |hash|
          competition.attributes = hash
          hash.keys.each do |key|
            competition[key] = options[:params][key] if options[:params][key].present?
          end
        end
        competition.country ||= CityCountry.find_by(city: competition.city).try(:country)

        ## time_schdule, date, tz
        competition.start_date = parsed[:time_schedule].map {|d| d[:starting_time]}.min.to_date || raise
        competition.end_date = parsed[:time_schedule].map {|d| d[:starting_time]}.max.to_date || raise
        competition.timezone = parsed[:time_schedule].first[:starting_time].time_zone.name || 'UTC'

        binding.pry
        competition.save! ## need to save here to create children

        debug('*' * 100)
        debug('%<name>s [%<short_name>s] (%<site_url>s)' % competition.attributes.symbolize_keys)

        ## for each categories, segments(scores)
        parsed[:category_results].each do |item|
          category = Category.find_by(name: item[:category]) || next   ## TODO: warning
          next unless categories_to_update.include?(category)
          update_category_results(competition, category, item[:result_url])
        end

        ## segments
        parsed[:segment_results].each do |item|
          next if item[:result_url].blank?

          category = Category.find_by(name: item[:category]) || next
          segment = Segment.find_by(name: item[:segment]) || raise

          starting_time = parsed[:time_schedule].find {|ts| ts[:category] == item[:category] && ts[:segment] == item[:segment] }[:starting_time] || raise
          update_performed_segment(competition, category, segment, item[:panel_url], starting_time: starting_time)
          update_segment_results(competition, category, segment, item[:result_url])
          update_scores(competition, category, segment, item[:score_url])
        end
      end
      ## ensure to return competition object
    end ## transaction
  end

  ################
  def update_performed_segment(competition, category, segment, panel_url, starting_time: starting_time)
    parsed_panels = parsers[:panel].parse(panel_url)
    competition.performed_segments.create! do |ps|
      ps.update(category: category, segment: segment, starting_time: starting_time)
      ## panels
      if parsed_panels[:judges].present?
        num_panels = parsed_panels[:judges].size - 1
        1.upto(num_panels).each do |i|
          next if parsed_panels[:judges][i].nil?    ## || parsed_panels[:judges][i][:name] == '-'

          name = normalize_persons_name(parsed_panels[:judges][i][:name])
          nation = parsed_panels[:judges][i][:nation]
          panel = Panel.find_or_create_by(name: name)
          if (nation != 'ISU') && panel.nation.blank?
            debug("... nation updated: #{nation} for #{name}", indent: 5)
            panel.update(nation: nation)
          end
          debug("Judge No #{i}: #{panel.name} (#{panel.nation})", indent: 5)
          absence = (panel.name == '-') ? true : false
          ps.officials.create!(number: i, panel: panel, absence: absence)
        end
      end
    end
  end

  ################
  def update_category_results(competition, category, result_url)
    return if result_url.blank?

    ActiveRecord::Base.transaction do
      parsers[:category_result].parse(result_url).each do |parsed|
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
    ActiveRecord::Base.transaction do
      parsers[:segment_result].parse(result_url).tap do |items|
        items.each do |parsed|
          competition.scores.create!(category: category, segment: segment) do |score|
            relevant_cr = competition.category_results
                          .where(category: category, "#{segment.segment_type}_ranking": parsed[:ranking]).first
            skater = relevant_cr.try(:skater) ||
                     find_or_create_skater(parsed[:isu_number], parsed[:skater_name], parsed[:nation], category)
            ps = competition.performed_segments
                 .where(category: category, segment: segment).first || raise('no relevant Performed Segment')

            score.attributes = slice_common_attributes(score, parsed)
                               .merge(
                                 skater: skater,
                                 # performed_segment: ps,
                                 date: ps.starting_time.to_date
                               )

            if relevant_cr
              # score.update(category_result: relevant_cr)
              score.save!           ## need to save here
              relevant_cr.update(segment.segment_type => score)
            end
          end  ## each result
        end
      end
    end
  end

  ################
  def update_scores(competition, category, segment, score_url)
    parsers[:score].parse(score_url).each do |parsed|
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
      details.each.with_index(1) do |value, i|
        dev = value - avg
        official = competition.performed_segments
                   .where(category: category, segment: segment).first.officials
                   .where(number: i).first || raise("no relevant officail: #{i}")
        element.element_judge_details
          .create(number: i, value: value, official: official, average: avg, deviation: dev, abs_deviation: dev.abs)
      end
    end
    ### component
    score.components.each do |component|
      details = component.judges.split(/\s/).map(&:to_f)
      avg = details.sum / details.count
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

  ################
  ## utils
  def slice_common_attributes(model, hash)
    hash.slice(*model.class.column_names.map(&:to_sym) & hash.keys)
  end

  def find_or_create_skater(isu_number, skater_name, nation, category)
    normalized = normalize_persons_name(skater_name)
    @skater_name_correction ||= YAML.load_file(Rails.root.join('config', 'skater_name_correction.yml'))
    corrected_skater_name = @skater_name_correction[normalized] || normalized
    Skater.find_or_create_by_isu_number_or_name(isu_number, corrected_skater_name) do |sk|
      sk.attributes = {
        category: Category.where(team: false, category_type: category.category_type).first,
        nation:   nation,
      }
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
