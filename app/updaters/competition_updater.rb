class CompetitionUpdater
  def initialize(parser_type = CompetitionParser::DEFAULT_PARSER, verbose: false)
    @parser = "CompetitionParser::#{parser_type.to_s.camelize}".constantize.new
    @verbose = verbose
  end

  def update_competition(site_url, date_format: nil, comment: nil, city: nil, name: nil)
    parsed = @parser.parse_summary(site_url, date_format: date_format).presence || (return nil)

    ActiveRecord::Base.transaction do
      Competition.create do |competition|
        attrs = competition.class.column_names.map(&:to_sym) & parsed.keys
        competition.attributes = parsed.slice(*attrs)
        competition.country ||= CityCountry.find_by(city: city).try(:country)

        competition.name = name if name.present?
        competition.city = city if city.present?
        competition.comment = comment if comment.present?
        #competition.normalize
        competition.save!  ## need to save here to create children

        if @verbose
          puts "*" * 100
          puts "%<name>s [%<short_name>s] (%<site_url>s)" % competition.attributes.symbolize_keys
        end

        ## for each categories, segments(scores)
        parsed[:categories].each do |category, cat_item|
          next unless Category.accept?(category)

          update_result(competition, category, cat_item[:result_url])
          parsed[:segments][category].each do |segment, seg_item|
            update_score(competition, category, segment, seg_item[:score_url], date: seg_item[:date])
          end
        end
      end
      ## ensure to return competition object
    end  ## transaction
  end
  ################
  def update_result(competition, category, result_url)
    @parser.parse_result(result_url).each do |result_parsed|
      competition.results.create!(category: category) do |result|
        ActiveRecord::Base.transaction {
          attrs = result.class.column_names.map(&:to_sym) & result_parsed.keys
          result.update(result_parsed.slice(*attrs))
          result.skater = Skater.find_or_create_by_isu_number_or_name(result.isu_number, result_parsed[:skater_name]) do |sk|
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
  def update_score(competition, category, segment, score_url, date: nil)
    @parser.parse_score(score_url).each do |sc_parsed|
      competition.scores.create!(category: category, segment: segment) do |score|
        cr_rels = competition.results.where(category: category)
        relevant_cr =
          cr_rels.find_by_skater_name(sc_parsed[:skater_name]) ||
          cr_rels.where(category: category).find_by_segment_ranking(segment, sc_parsed[:ranking]) ||
          raise("no relevant category results for %<skater_name>s %<segment>s#%<ranking>d" % sc_parsed.merge(segment: segment))

        ActiveRecord::Base.transaction {
          score.attributes = {
            result: relevant_cr,
            skater: relevant_cr.skater,
            date: date,
          }
          attrs = score.class.column_names.map(&:to_sym) & sc_parsed.keys
          score.update(sc_parsed.slice(*attrs))

          sc_parsed[:elements].map {|e| score.elements.create(e)}
          sc_parsed[:components].map {|e| score.components.create(e)}
        
          ## update segment details into results
          segment_type = (segment =~ /SHORT/) ? :short : :free
          [:tss, :tes, :pcs, :deductions].each do |key|
            score.result["#{segment_type}_#{key}"] = score[key]
            score.result["#{segment_type}_bv"] = score[:base_value]
            score.result.save!
          end

          puts score.summary if @verbose
=begin
              ## judge details
              if self.start_date > Time.zone.parse("2016-7-1") # was random order in the past
                ### elements
                score.elements.each do |element|
                  element.judges.split(/\s/).each_with_index do |value, i|
                    #next if panels[:judges].count <= i+1
                    element.element_judge_details.create(panel_name: panels[:judges][i+1][:name],
                                                         panel_nation: panels[:judges][i+1][:nation],
                                                         number: i, value: value)
                  end
                end

                ### component
                score.components.each do |component|
                  component.judges.split(/\s/).each_with_index do |value, i|
                    #next if panels[:judges].count <= i+1
                    component.component_judge_details.create(panel_name: panels[:judges][i+1][:name],
                                                             panel_nation: panels[:judges][i+1][:nation],
                                                             number: i, value: value)
                  end
                end
              end
=end
        }
      end
    end
  end
end
