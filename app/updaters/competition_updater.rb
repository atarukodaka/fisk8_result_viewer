class CompetitionUpdater
  def initialize(parser_type = CompetitionParser::DEFAULT_PARSER, verbose: false)
    @parser = "CompetitionParser::#{parser_type.to_s.camelize}".constantize.new
    @verbose = verbose
  end
  def update_competition(site_url, date_format: nil, comment: nil, city: nil, name: nil)
    parsed = @parser.parse_summary(site_url, date_format: date_format).presence || (return nil)
    #competition = nil
    ActiveRecord::Base.transaction do
      competition = Competition.create do |competition|
        attrs = competition.class.column_names.map(&:to_sym) & parsed.keys
        competition.attributes = parsed.slice(*attrs)
        normalize_competition_info(competition)
        competition.country ||= CityCountry.find_by(city: city).try(:country)
        if @verbose
          puts "*" * 100
          puts "%<name>s [%<short_name>s] (%<site_url>s)" % competition.attributes.symbolize_keys
        end

        competition.save!  ## need to save here

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
        attrs = result.class.column_names.map(&:to_sym) & result_parsed.keys
        result.attributes = result_parsed.slice(*attrs)
        ActiveRecord::Base.transaction {
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
          score.attributes = sc_parsed.slice(*attrs)
          
          ## set abbr, name
          if score.name.present?
            category_abbr = Category.find_by(name: category).try(:abbr)
            segment_abbr = segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'
            
            score.name = [competition.try(:short_name), category_abbr, segment_abbr, score.ranking].join('-')
          end
          score.save!  ## need to save score to create children
          sc_parsed[:elements].map {|e| score.elements.create(e)}
          sc_parsed[:components].map {|e| score.components.create(e)}
        
          puts score.summary if @verbose
        
          ## update segment details into results
          segment_type = (segment =~ /SHORT/) ? :short : :free
          [:tss, :tes, :pcs, :deductions].each do |key|
            score.result["#{segment_type}_#{key}"] = score[key]

            score.result["#{segment_type}_bv"] = score[:base_value]
            score.result.save!
          end
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
  ################
  private
  def normalize_competition_info(competition)
    year = competition.start_date.year
    country_city = competition.country || competition.city.to_s.upcase.gsub(/\s+/, '_')        
    ary = case competition.name
          when /^ISU Grand Prix .*Final/, /^ISU GP.*Final/
            [:isu, :gp, "GPF#{year}"]
          when /^ISU GP/
            [:isu, :gp, "GP#{country_city}#{year}"]
          when /Olympic/
            [:isu, :olympic, "OLYMPIC#{year}"]
          when /^ISU World Figure/, /^ISU World Championships/
            [:isu, :world, "WORLD#{year}", "ISU World Championships #{year}"]
          when /^ISU Four Continents/
            [:isu, :fcc, "FCC#{year}", "ISU Four Continents Championships #{year}"]
          when /^ISU European/
            [:isu, :euro, "EURO#{year}", "ISU European Championships #{year}"]
          when /^ISU World Team/
            [:isu, :team, "TEAM#{year}"]
          when /^ISU World Junior/
            [:isu, :jworld, "JWORLD#{year}"]
          when /^ISU JGP/, /^ISU Junior Grand Prix/
            [:isu, :jgp, "JGP#{country_city}#{year}"]
            
          when /^Finlandia Trophy/
            [:challenger, :finlandia, "FINLANDIA#{year}", "Finlandia Trophy #{year}"]
          when /Warsaw Cup/
            [:challenger, :warshaw, "WARSAW#{year}", "Warsaw Cup #{year}"]
          when /Autumn Classic/
            [:challenger, :aci, "ACI#{year}"]
          when /Nebelhorn/
            [:challenger, :nebelhorn, "NEBELHORN#{year}", "Nebelhorn Trophy #{year}"]
          when /Lombardia/
            [:challenger, :lombaridia, "LOMBARDIA#{year}", "Lombardia Trophy #{year}"]
          when /Ondrej Nepela/
            [:challenger, :nepela, "NEPELA#{year}", "Ondrej Nepela Trophy #{year}"]
          else
            [:unknown, :unknown, competition.name.to_s.gsub(/\s+/, '_')]
          end
    competition.competition_class ||= ary[0]
    competition.competition_type ||= ary[1]
    competition.short_name ||= ary[2]
    competition.name = ary[3] if ary[3]
  end
end
