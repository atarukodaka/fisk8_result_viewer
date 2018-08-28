class CompetitionUpdater
  def initialize(parser_type: CompetitionParser::DEFAULT_PARSER, verbose: false)
    @parser = "CompetitionParser::#{parser_type.to_s.camelize}".constantize.new
    @verbose = verbose
  end

  def update_competition(site_url, date_format: nil, force: false, params: {})
    if (competitions = Competition.where(site_url: site_url).presence)
      if force
        competitions.map(&:destroy)
      else
        puts "skip: '#{site_url}' already exists"
        return nil
      end
    end
    
    parsed = @parser.parse_summary(site_url, date_format: date_format).presence || (return nil)

    ActiveRecord::Base.transaction do
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
            ###
            competition.performed_segments.create do |ps|
              ps.category = category
              ps.segment = segment
              ps.starting_time = seg_item[:time]
            end
            ###
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
    @parser.parse_category_result(result_url).each do |result_parsed|
      competition.category_results.create!(category: category) do |result|
        ActiveRecord::Base.transaction {

          attrs = result.class.column_names.map(&:to_sym) & result_parsed.keys
          result.update(result_parsed.slice(*attrs))
          result.skater = Skater.find_or_create_by_isu_number_or_name(result_parsed[:isu_number], result_parsed[:skater_name]) do |sk|
            sk.attributes = {
              category: category.sub(/^JUNIOR */, ''),
              nation: result_parsed[:nation],
            }
          end
          result.save!
        }
        puts result.summary if @verbose
      end
    end
  end 
  ################
  def update_score(competition, category, segment, score_url, result_url, additionals = {})
    segment_results = @parser.parse_segment_result(result_url)

    @parser.parse_score(score_url).each do |sc_parsed|
      competition.scores.create!(category: category, segment: segment) do |score|
        ActiveRecord::Base.transaction {
          ## find skater
          h = segment_results.select {|h| h[:starting_number] == sc_parsed[:starting_number] }.first ## TODO: for nil

          skater = ((h[:isu_number].present? ) ?
                     Skater.where(isu_number: h[:isu_number]).first :
                     Skater.where(name: h[:skater_name]).first ) || raise("no such skater")

          ## find relevant category result
          segment_type = (segment =~ /SHORT/) ? :short : :free
          relevant_cr = competition.category_results.where(category: category, "#{segment_type}_ranking": sc_parsed[:ranking]).first
          
          ## set attributes
          score.attributes = {
            category_result: relevant_cr,
            skater: skater,
            #segment_starting_time: segment_starting_time,
          }.merge(additionals)
          attrs = score.class.column_names.map(&:to_sym) & sc_parsed.keys
          score.attributes = sc_parsed.slice(*attrs)

          score.save!  ## need to save here to create children
          
          sc_parsed[:elements].map {|e| score.elements.create(e)}
          sc_parsed[:components].map {|e| score.components.create(e)}

          score.update(elements_summary: score.elements.map(&:name).join('/'))
          score.update(components_summary: score.components.map(&:value).join('/'))
          puts score.summary if @verbose
        }
      end
    end
  end
end
