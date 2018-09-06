class CompetitionUpdater
  def initialize(parser_type: CompetitionParser::DEFAULT_PARSER, verbose: false)
    @parser = "CompetitionParser::#{parser_type.to_s.camelize}".constantize.new
    @verbose = verbose
  end

  def update_competition(site_url, date_format: nil, force: false, params: {})
    ActiveRecord::Base.transaction do
      if (competitions = Competition.where(site_url: site_url).presence)
        if force
          competitions.map(&:destroy)
        else
          puts "skip: '#{site_url}' already exists"
          return nil
        end
      end
      
      parsed = @parser.parse_summary(site_url, date_format: date_format).presence || (return nil)
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
        parsed[:categories].each do |category, cat_item|
          next unless Category.accept?(category)
          update_category_result(competition, category, cat_item[:result_url])

          parsed[:segments][category].each do |segment, seg_item|
            next if seg_item[:result_url].blank?

            competition.performed_segments.create do |ps|
              ps.category = category
              ps.segment = segment
              ps.starting_time = seg_item[:time]
            end

            update_score(competition, category, segment, seg_item[:score_url], seg_item[:result_url], date: seg_item[:time].to_date)
          end
        end
      end
      ## ensure to return competition object
    end  ## transaction
  end
  ################
  def update_category_result(competition, category, result_url)
    return if result_url.blank?
    
    ActiveRecord::Base.transaction {
      @parser.parse_category_result(result_url).each do |result_parsed|
        competition.category_results.create!(category: category) do |result|
          attrs = result.class.column_names.map(&:to_sym) & result_parsed.keys
          result.update(result_parsed.slice(*attrs))
          result.skater = Skater.find_or_create_by_isu_number_or_name(result_parsed[:isu_number], result_parsed[:skater_name]) do |sk|
            sk.attributes = {
              category: category.sub(/^JUNIOR */, ''),
              nation: result_parsed[:nation],
            }
          end
          result.save!
          puts result.summary if @verbose
        end
      end
    }
  end
  ################
  def update_score(competition, category, segment, score_url, result_url, additionals = {})
    segment_results = @parser.parse_segment_result(result_url)
    segment_type = (segment =~ /SHORT/ || segment =~ /RHYTHM/) ? :short : :free

    @parser.parse_score(score_url).each do |sc_parsed|
      ActiveRecord::Base.transaction {
        competition.scores.create!(category: category, segment: segment) do |score|
          ## find relevant cr
          relevant_cr = competition.category_results.where(category: category, "#{segment_type}_ranking": sc_parsed[:ranking]).first

          ## find skater
          skater = relevant_cr.try(:skater) ||
                   begin
                     elem = segment_results.select {|h| h[:starting_number] == sc_parsed[:starting_number] }.first || {}
                     skater_name = elem[:skater_name] || sc_parsed[:skater_name]
                     Skater.find_or_create_by_isu_number_or_name(elem[:isu_number], skater_name) do |sk|
                       sk.nation = sc_parsed[:nation]
                     end
                   end
          
          ## set attributes
          attrs = score.class.column_names.map(&:to_sym) & sc_parsed.keys
          score.attributes = sc_parsed.slice(*attrs).merge(additionals).merge(
            {
              skater: skater,
              segment_type: segment_type,
            })
          score.save!  ## need to save here to create children

          relevant_cr.update(segment_type => score) if relevant_cr
          sc_parsed[:elements].map {|e| score.elements.create(e)}
          sc_parsed[:components].map {|e| score.components.create(e)}

          score.update(elements_summary: score.elements.map(&:name).join('/'))
          score.update(components_summary: score.components.map(&:value).join('/'))
          puts score.summary if @verbose
        end
      }
    end
  end
end
