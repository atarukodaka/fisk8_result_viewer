class Competition < ApplicationRecord
  ## relations
  has_many :results, dependent: :destroy
  has_many :scores, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  

  ## scopes
  scope :recent, ->(){ order("start_date desc")  }
  #scope :name_matches, ->(v){ where("name like ? ", "%#{v}%") }
  #scope :site_url_matches, ->(v){ where("site_url like ? ", "%#{v}%") }

  ## entries
  def categories
    scores.pluck(:category).uniq
  end
  ## updater
  def clean
    results.map(&:destroy)
    scores.map(&:destroy)
  end
  def update(verbose: false, params: {})
    ActiveRecord::Base.transaction do
      clean
      
      ## parse
      parser = "CompetitionParser::#{parser_type.camelize}".constantize.new
      parsed = parser.parse_summary(site_url).presence || (return nil)
      attrs = self.class.column_names.map(&:to_sym) & parsed.keys
      self.attributes = parsed.slice(*attrs)
      self.attributes = params
      
      normalize_name
      self.country ||= CityCountry.find_by(city: city).try(:country)
      save!
      if verbose
        puts "*" * 100
        puts "%<name>s [%<short_name>s] (%<site_url>s)" % attributes.symbolize_keys
      end
      
      ## categories
      parsed[:categories].each do |category, cat_item|
        next unless Category.accept?(category)
        #Parsers.parser(:result, parser_type.to_sym).parse(cat_item[:result_url]).each do |result_parsed|
        parser.parse_result(cat_item[:result_url]).each do |result_parsed|
          results.create!(category: category) do |result|
            result.update(result_parsed)
            puts result.summary if verbose
          end
        end
        
        # segment scores
        parsed[:segments][category].each do |segment, seg_item|
          #Parser::ScoreParser.new.parse(seg_item[:score_url]).each do |sc_parsed|
          panels = parser.parse_panel(seg_item[:panel_url])

          parser.parse_score(seg_item[:score_url]).each do |sc_parsed|
            scores.create!(category: category, segment: segment) do |score|
              cr_rels = results.where(category: category)
              relevant_cr =
                cr_rels.find_by_skater_name(sc_parsed[:skater_name]) ||
                cr_rels.where(category: category).find_by_segment_ranking(segment, sc_parsed[:ranking]) ||
                raise("no relevant category results for %<skater_name>s %<segment>s#%<ranking>d" % sc_parsed.merge(segment: segment))
              score.attributes = {
                result: relevant_cr,
                skater: relevant_cr.skater,
                date: seg_item[:date],
              }
              score.update(sc_parsed)
              puts score.summary if verbose

              ## update segment details into results
              segment_type = (segment =~ /SHORT/) ? :short : :free
              [:tss, :tes, :pcs, :deductions].each do |key|
                score.result["#{segment_type}_#{key}"] = score[key]
              end
              score.result["#{segment_type}_bv"] = score[:base_value]
              score.result.save

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
            end
          end

          
          #binding.pry
        end # segments
      end # categories
      
      ## udpate total_bv, goe into results
      ActiveRecord::Base.transaction {
        results.each do |result|
          result.total_bv = 0
          result.total_goe = 0
          result.scores.each do |score|
            result.total_bv += score.base_value
            result.total_goe += score.elements.map(&:goe).sum
          end
          result.save!
        end
      }
      self
    end # transaction
  end # udpate

  ################
  private
  def normalize_name
    year = self.start_date.year
    country_city = country || city.to_s.upcase.gsub(/\s+/, '_')        
    ary = case name
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
            [:challenger, :nepela, "NEPELA#{year}", "Ondrej Nepeta Trophy #{year}"]
          else
            [:unknown, :unknown, name.to_s.gsub(/\s+/, '_')]
          end
    self.competition_class ||= ary[0]
    self.competition_type ||= ary[1]
    self.short_name ||= ary[2]
    self.name = ary[3] if ary[3]
    
    self
  end
end
