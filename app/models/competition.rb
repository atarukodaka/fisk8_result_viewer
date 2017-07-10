class Competition < ApplicationRecord
  #after_initialize :set_default_values
  before_save :set_short_name
  
  ACCEPT_CATEGORIES = Category.all.map {|c| c.name.to_sym}

  ## relations
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  

  ## scopes
  scope :recent, ->(){ order("start_date desc")  }
  scope :name_matches, ->(v){ where("name like ? ", "%#{v}%") }
  scope :site_url_matches, ->(v){ where("site_url like ? ", "%#{v}%") }
    
  ## class methods
  class << self
    def destroy_existings_by_url(url)
      ActiveRecord::Base.transaction {
        Competition.where(site_url: url).map(&:destroy)
      }
    end
    def create_competition(url, parser_type: :isu_generic, comment: nil, accept_categories: nil)
      accept_categories ||= ACCEPT_CATEGORIES
      if c = Competition.find_by(site_url: url)
        puts "skip: #{url} as already existing"
        return c
      end
      ActiveRecord::Base.transaction do
        parser = Parsers.parser(:competition, parser_type)
        summary = parser.parse(url)
        competition = Competition.create do |comp|
          [:site_url, :name, :city, :country, :start_date, :end_date, :season, ].each do |key|
            comp[key] = summary.send(key)
          end
        end

        competition.parser_type = parser_type
        competition.comment = comment
        #competition.country ||= @city_country[competition.city]  # TODO: country
        competition.save!  # TODO
        puts "*" * 100
        puts "%<name>s [%<short_name>s] (%<site_url>s)" % competition.attributes.symbolize_keys

        summary.categories.each do |category|
          next unless accept_categories.include?(category.to_sym)
          result_url = summary.result_url(category)
          CategoryResult.create_category_result(result_url, competition, category, parser_type: parser_type)
          
          # segment
          summary.segments(category).each do |segment|
            score_url = summary.score_url(category, segment)
            date = summary.starting_time(category, segment)
            Score.create_score(score_url, competition, category, segment, attributes: {date: date})            
          end
        end
        competition
      end
    end
  end
  ################
  private
  def set_short_name
    year = self.start_date.year
    country_city = country || city.to_s.upcase.gsub(/\s+/, '_')        
    ary = case name
          when /^ISU Grand Prix .*Final/, /^ISU GP.*Final/
            [:gp, "GPF#{year}", true]
          when /^ISU GP/
            [:gp, "GP#{country_city}#{year}", true]
          when /Olympic/
            [:olympic, "OLYMPIC#{year}", true]
          when /^ISU World Figure/, /^ISU World Championships/
            [:world, "WORLD#{year}", true]
          when /^ISU Four Continents/
            [:fcc, "FCC#{year}", true]
          when /^ISU European/
            [:euro, "EURO#{year}", true]
          when /^ISU World Team/
            [:team, "TEAM#{year}", true]
          when /^ISU World Junior/
            [:jworld, "JWORLD#{year}", true]
          when /^ISU JGP/, /^ISU Junior Grand Prix/
            [:jgp, "JGP#{country_city}#{year}", true]
            
          when /^Finlandia Trophy/
            [:challenger, "FINLANDIA#{year}", false]
          when /Warsaw Cup/
            [:challenger, "WARSAW#{year}", false]
          when /Autumn Classic/
            [:challenger, "ACI#{year}", false]
          when /Nebelhorn/
            [:challenger, "NEBELHORN#{year}", false]
          when /Lombardia/
            [:challenger, "LOMBARDIA#{year}", false]
          when /Ondrej Nepela/
            [:challenger, "NEPELA#{year}", false]
          else
            [:unknown, name.to_s.gsub(/\s+/, '_'), false]
          end
    self.competition_type ||= ary[0]
    self.short_name ||= ary[1]
    self.isu_championships ||= ary[2]
    self
  end
  
end
