module CompetitionUpdater::Results
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
    parsed = parser(:panel).parse(panel_url)
    competition.performed_segments.create! do |ps|
      ps.update(category: category, segment: segment, starting_time: starting_time)

      ## officials
      parsed[:judges].each do |item|
        if item[:name] == '-'
          debug('absent', indent: 3)
        else
          panel = update_panel(name: item[:name], nation: item[:nation])
          ps.officials.create!(number: item[:number], panel: panel)
          debug("Judge No #{item[:number]}: #{panel.name} (#{panel.nation})", indent: 5)
        end
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
end  
