class Competition < ApplicationRecord
  ## relations
  has_many :results, dependent: :destroy
  has_many :scores, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  

  ## scopes
  scope :recent, ->(){ order("start_date desc")  }
  scope :name_matches, ->(v){ where("name like ? ", "%#{v}%") }
  scope :site_url_matches, ->(v){ where("site_url like ? ", "%#{v}%") }

  ## entries
  def categories
    scores.pluck(:category).uniq
  end
  ## updater
  def clean
    results.map(&:destroy)
    scores.map(&:destroy)
  end
  def update!
    ActiveRecord::Base.transaction do
      clean
      
      ## parse
      #attrs = [:site_url, :name, :city, :country, :start_date, :end_date, :season, ]
      parsed = Parsers.parser(:competition, parser_type.to_sym).parse(site_url)
      attrs = self.class.column_names.map(&:to_sym) & parsed.keys
      self.attributes = parsed.slice(*attrs)

      set_short_name
      self.country ||= CityCountry.find_by(city: city).try(:country)
      save!
      puts "*" * 100
      puts "%<name>s [%<short_name>s] (%<site_url>s)" % attributes.symbolize_keys

      ## categories
      parsed[:categories].each do |category, cat_item|
        next unless Category.accept?(category)
        Parsers.parser(:result, parser_type.to_sym).parse(cat_item[:result_url]).each do |cr_parsed|
          results.create!(category: category) do |cr|
            cr.update!(cr_parsed)
            puts cr.summary
          end
        end
        
        # segments
        parsed[:segments][category].each do |segment, seg_item|
          Parser::ScoreParser.new.parse(seg_item[:score_url]).each do |sc_parsed|
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
              score.update!(sc_parsed)
              puts score.summary
            end
          end
        end # segments
      end # categories
      self
    end # transaction
  end # udpate

  ################
  private
  def set_short_name
    year = self.start_date.year
    country_city = country || city.to_s.upcase.gsub(/\s+/, '_')        
    ary = case name
          when /^ISU Grand Prix .*Final/, /^ISU GP.*Final/
            [:gp, "GPF#{year}", :isu]
          when /^ISU GP/
            [:gp, "GP#{country_city}#{year}", :isu]
          when /Olympic/
            [:olympic, "OLYMPIC#{year}", :isu]
          when /^ISU World Figure/, /^ISU World Championships/
            [:world, "WORLD#{year}", :isu]
          when /^ISU Four Continents/
            [:fcc, "FCC#{year}", :isu]
          when /^ISU European/
            [:euro, "EURO#{year}", :isu]
          when /^ISU World Team/
            [:team, "TEAM#{year}", :isu]
          when /^ISU World Junior/
            [:jworld, "JWORLD#{year}", :isu]
          when /^ISU JGP/, /^ISU Junior Grand Prix/
            [:jgp, "JGP#{country_city}#{year}", :isu]
            
          when /^Finlandia Trophy/
            [:finlandia, "FINLANDIA#{year}", :challenger]
          when /Warsaw Cup/
            [:warshaw, "WARSAW#{year}", :challenger]
          when /Autumn Classic/
            [:aci, "ACI#{year}", :challenger]
          when /Nebelhorn/
            [:nebelhorn, "NEBELHORN#{year}", :challenger]
          when /Lombardia/
            [:lombaridia, "LOMBARDIA#{year}", :challenger]
          when /Ondrej Nepela/
            [:nepela, "NEPELA#{year}", :challenger]
          else
            [:unknown, name.to_s.gsub(/\s+/, '_'), :unknown]
          end
    self.competition_type ||= ary[0]   # if competition_type.blank?
    self.short_name ||= ary[1] # if short_name.blank?
    #self.isu_championships ||= ary[2] # if isu_championships.blank? # TODO
    self.competition_class ||= ary[2]
    self
  end
  
end
