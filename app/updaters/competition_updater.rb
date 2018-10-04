class CompetitionUpdater
  def initialize(parser_type: nil, verbose: false, enable_judge_details: nil)
    @parsers = CompetitionParser::ParserBuilder.build(parser_type, verbose: verbose)
    @verbose = verbose
    @enable_judge_details = enable_judge_details
  end

  def within_season?(season, from: nil, to: nil)
    if from && (season < from)
      puts "...skip: #{season} is before #{from}" if @verbose
      false
    elsif to && (season > to)
      puts "...skip: #{season} is after #{to}" if @verbose
      false
    else
      true
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

  def update_competition(site_url, date_format: nil, force: false, categories: nil, season_from: nil, season_to: nil, params: {})
    categories_to_update = get_categories_to_update(categories)

    ActiveRecord::Base.transaction do
      ## existing check
      if (competitions = Competition.where(site_url: site_url).presence)
        if force
          competitions.map(&:destroy)
        else
          puts "skip: '#{site_url}' already exists"
          return nil
        end
      end

      parsed = @parsers[:summary].parse(site_url, date_format: date_format).presence || (return nil)

      ## check season from/to
      unless within_season?(parsed[:season], from: season_from, to: season_to)
        puts '  skip: not within specific season'
        return
      end

      Competition.create do |competition|
        attrs = competition.class.column_names.map(&:to_sym) & parsed.keys
        competition.attributes = parsed.slice(*attrs)

        [:name, :city, :comment].each do |key|
          competition[key] = params[key] if params[key].present?
        end
        competition.country ||= CityCountry.find_by(city: competition.city).try(:country)
        competition.normalize
        competition.save! ## need to save here to create children

        puts '*' * 100 + "\n%<name>s [%<short_name>s] (%<site_url>s)" % competition.attributes.symbolize_keys if @verbose

        ## for each categories, segments(scores)
        parsed[:categories].each do |category_str, cat_item|
          category = Category.find_by(name: category_str) || next
          next unless categories_to_update.include?(category)

          update_category_result(competition, category, cat_item[:result_url])

          parsed[:segments][category_str].each do |segment_str, seg_item|
            next if seg_item[:result_url].blank?

            segment = Segment.find_by(name: segment_str)

            update_performed_segment(competition, category, segment, seg_item[:panel_url], seg_item[:time])
            update_score(competition, category, segment, seg_item[:score_url], seg_item[:result_url], date: seg_item[:time].to_date)
          end
        end
      end
      ## ensure to return competition object
    end ## transaction
  end

  ################
  def update_performed_segment(competition, category, segment, panel_url, starting_time)
    parsed_panels = @parsers[:panel].parse(panel_url) # if @enable_judge_details
    competition.performed_segments.create do |ps|
      ps.update(category: category, segment: segment, starting_time: starting_time)
      ## panels
      if parsed_panels[:judges].present?
        num_panels = parsed_panels[:judges].size - 1
        1.upto(num_panels).each do |i|
          next if parsed_panels[:judges][i].nil?

          name = normalize_persons_name(parsed_panels[:judges][i][:name])
          nation = parsed_panels[:judges][i][:nation]
          panel = Panel.find_or_create_by(name: name)
          if (nation != 'ISU') && panel.nation.blank?
            puts "       ... nation updated: #{nation} for #{name}" if @verbose
            panel.update(nation: nation)
          end
          puts "  Judge No #{i}: #{panel.name} (#{panel.nation})" if @verbose
          absence = (panel.name == '-') ? true : false
          ps.officials.create(number: i, panel: panel, absence: absence)
        end
      end
    end
  end

  ################
  def update_category_result(competition, category, result_url)
    return if result_url.blank?

    ActiveRecord::Base.transaction do
      @parsers[:category_result].parse(result_url).each do |result_parsed|
        competition.category_results.create!(category: category) do |result|
          attrs = result.class.column_names.map(&:to_sym) & result_parsed.keys
          result.update(result_parsed.slice(*attrs))
          result.skater = find_or_create_skater(result_parsed[:isu_number], result_parsed[:skater_name],
                                                result_parsed[:nation], category)
          result.save!
          puts result.summary if @verbose
        end
      end
    end
  end

  ################
  def update_judge_details(competition, category, segment, score)
    return if competition.start_date <= Time.zone.parse('2016-7-1') # was random order in the past

    ### elements
    score.elements.each do |element|
      details = element.judges.split(/\s/).map(&:to_f)
      avg = details.sum / details.count
      details.each.with_index(1) do |value, i|
        dev = value - avg
        official = competition.performed_segments.where(category: category, segment: segment).first.officials.where(number: i).first || raise("no relevant officail: #{i}")
        element.element_judge_details.create(number: i, value: value, official: official, average: avg, deviation: dev, abs_deviation: dev.abs)
      end
    end
    ### component
    score.components.each do |component|
      details = component.judges.split(/\s/).map(&:to_f)
      avg = details.sum / details.count
      details.each.with_index(1) do |value, i|
        dev = value - avg
        official = competition.performed_segments.where(category: category, segment: segment).first.officials.where(number: i).first || raise("no relevant officail: #{i}")
        component.component_judge_details.create(number: i, value: value, official: official, average: avg, deviation: dev)
      end
    end
  end

  def update_score(competition, category, segment, score_url, result_url, additionals = {})
    segment_results = nil
    segment_type = segment.segment_type

    @parsers[:score].parse(score_url).each do |sc_parsed|
      ActiveRecord::Base.transaction do
        competition.scores.create!(category: category, segment: segment) do |score|
          ## find relevant cr
          relevant_cr = competition.category_results.where(category: category, "#{segment_type}_ranking": sc_parsed[:ranking]).first

          ## find skater
          skater = relevant_cr.try(:skater) ||
                   begin
                     segment_results ||= @parsers[:segment_result].parse(result_url)
                     seg_result = segment_results.select { |h| h[:starting_number] == sc_parsed[:starting_number] }.first || {}
                     skater_name = seg_result[:skater_name] || sc_parsed[:skater_name]
                     find_or_create_skater(seg_result[:isu_number], skater_name, sc_parsed[:nation], category)
                   end

          ## set attributes
          attrs = score.class.column_names.map(&:to_sym) & sc_parsed.keys
          score.attributes = sc_parsed.slice(*attrs).merge(additionals)
          score.update(skater:            skater,
                       performed_segment: competition.performed_segments.where(category: category, segment: segment).first) ## need to save here to create children

          if relevant_cr
            relevant_cr.update(segment_type => score)
            score.update(category_result: relevant_cr)
          end
          sc_parsed[:elements].map { |e| score.elements.create(e) }
          sc_parsed[:components].map { |e| score.components.create(e) }

          score.update(elements_summary: score.elements.map(&:name).join('/'))
          score.update(components_summary: score.components.map(&:value).join('/'))
          puts score.summary if @verbose

          ## judge details

          update_judge_details(competition, category, segment, score) if @enable_judge_details
        end
      end
    end
  end ## def

  ################
  ## utils
  def find_or_create_skater(isu_number, skater_name, nation, category)
    normalized_skater_name = normalize_persons_name(skater_name)
    @skater_name_correction ||= YAML.load_file(File.join(Rails.root.join('config'), 'skater_name_correction.yml'))
    corrected_skater_name = @skater_name_correction[normalized_skater_name] || normalized_skater_name
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
