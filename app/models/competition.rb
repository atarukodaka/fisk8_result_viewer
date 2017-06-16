class Competition < ApplicationRecord
  #after_initialize :set_default_values
  before_save :set_short_name
  
  ## relations
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy

  
  ## validations
  #validates :cid, presence: true, uniqueness: true
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
  end
  private
  def set_default_values
    #self.cid ||= self.name || [self.competition_type, self.country, self.start_date.try(:year)].join("-")
    #self.cid ||= UUID.new.generate
  end

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
    self.cid ||= ary[1]
    self.isu_championships ||= ary[2]
=begin
    self.attributes = {
      competition_type: ary[0],
      cid: ary[1],
      isu_championships: ary[2],
    }
=end
  end
end
