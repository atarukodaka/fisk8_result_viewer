class CompetitionUpdater
  def initialize(parser_type: nil, verbose: false, enable_judge_details: false)
    @parsers = CompetitionParser::ParserBuilder::build(parser_type, verbose: verbose)
    @verbose = verbose
    @enable_judge_details = enable_judge_details
  end

  def update_competition(site_url, date_format: nil, force: false, categories: nil, params: {})
    accept_categories =
      if categories.nil?
        Category.all
      else
        categories.map do |cat|
          (cat.class == String) ? Category.where(name: cat).first : cat
        end.compact
      end
    ActiveRecord::Base.transaction do
      if (competitions = Competition.where(site_url: site_url).presence)
        if force
          competitions.map(&:destroy)
        else
          puts "skip: '#{site_url}' already exists"
          return nil
        end
      end
      parsed = @parsers[:summary].parse(site_url, date_format: date_format).presence || (return nil)
      Competition.create do |competition|
        attrs = competition.class.column_names.map(&:to_sym) & parsed.keys
        competition.attributes = parsed.slice(*attrs)

        [:name, :city, :comment].each do |key|
          competition[key] = params[key] if params[key].present?
        end
        competition.country ||= CityCountry.find_by(city: competition.city).try(:country)
        
        competition.normalize
        competition.save!  ## need to save here to create children

        if @verbose
          puts "*" * 100
          puts "%<name>s [%<short_name>s] (%<site_url>s)" % competition.attributes.symbolize_keys
        end
        ## for each categories, segments(scores)
        parsed[:categories].each do |category_str, cat_item|
          category = Category.find_by(name: category_str) || next
          next unless accept_categories.include?(category)

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
    end  ## transaction
  end
  def to_first_last_name(str)  ## naming of this function ?? and move to lib/util ??
    if str =~ /^([A-Z\-]+) ([A-Z][A-Za-z].*)$/
      [$2, $1].join(' ')
    else
      str
    end
  end
  ################
  def find_or_create_skater(isu_number, skater_name, nation, category)
    Skater.find_or_create_by_isu_number_or_name(isu_number, skater_name) do |sk|
      indivisual_senior_category = Category.where(team: false, category_type: category.category_type).first || raise("team senior category not found for #{category.name}")
      sk.attributes = {
        category: indivisual_senior_category,
        nation: nation,
      }
    end
  end
  ################
  def update_performed_segment(competition, category, segment, panel_url, starting_time)
    parsed_panels = @parsers[:panel].parse(panel_url) if @enable_judge_details
    competition.performed_segments.create do |ps|
      ps.category = category
      ps.segment = segment
      ps.starting_time = starting_time
      ps.save!
      if @enable_judge_details
        num_panels = parsed_panels[:judges].size - 1
        1.upto(num_panels).each do |i|
          name = to_first_last_name(parsed_panels[:judges][i][:name])
          nation = parsed_panels[:judges][i][:nation]
          panel = Panel.find_or_create_by(name: name)
          if nation != "ISU" && panel.nation.blank?
            panel.update(nation: nation)
          end
          #ps["judge%02d_id" % [i]] = panel.id
          puts "  Judge No #{i}: #{panel.name} (#{panel.nation})" if @verbose
          ps.officials.create(number: i, panel: panel)
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
          result.skater = find_or_create_skater(result_parsed[:isu_number], result_parsed[:skater_name], result_parsed[:nation], category)
          result.save!
          puts result.summary if @verbose
        end
      end
    end
  end
  ################
  def update_judge_details(competition, category, segment, score)
    return if competition.start_date <= Time.zone.parse("2016-7-1") # was random order in the past
    ### elements
    score.elements.each do |element|
      details = element.judges.split(/\s/).map(&:to_f)
      avg = details.sum/details.count
      #element.judges.split(/\s/).each_with_index do |value, i|
      details.each_with_index do |value, i|
        panel = competition.performed_segments.where(category: category, segment: segment).first.officials.where(number: i+1).first.panel
        element.element_judge_details.create(number: i+1, value: value, panel: panel, average: avg)
      end
    end
    ### component
    score.components.each do |component|
      component.judges.split(/\s/).each_with_index do |value, i|
        panel = competition.performed_segments.where(category: category, segment: segment).first.officials.where(number: i+1).first.panel
        component.component_judge_details.create(number: i+1, value: value, panel: panel)
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
                     seg_result = segment_results.select {|h| h[:starting_number] == sc_parsed[:starting_number] }.first || {}
                     skater_name = seg_result[:skater_name] || sc_parsed[:skater_name]
                     find_or_create_skater(seg_result[:isu_number], skater_name, sc_parsed[:nation], category)
                   end
          
          ## set attributes
          attrs = score.class.column_names.map(&:to_sym) & sc_parsed.keys
          score.attributes = sc_parsed.slice(*attrs).merge(additionals)
          score.skater = skater
          score.save!  ## need to save here to create children
          
          if relevant_cr
            relevant_cr.update(segment_type => score)
            score.update(category_result: relevant_cr)
          end
          sc_parsed[:elements].map {|e| score.elements.create(e)}
          sc_parsed[:components].map {|e| score.components.create(e)}
          
          score.update(elements_summary: score.elements.map(&:name).join('/'))
          score.update(components_summary: score.components.map(&:value).join('/'))
          puts score.summary if @verbose
          
          ## judge details
          update_judge_details(competition, category, segment, score) if @enable_judge_details
        end
      end
    end
  end
end
