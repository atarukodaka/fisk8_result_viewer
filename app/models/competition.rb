class Competition < ApplicationRecord
  before_save :normalize

  alias_attribute :competition_name, :name

  ## relations
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :performed_segments, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/ }

  ## scopes
  scope :recent, -> { order('start_date desc') }

  ## utils
  private
  
  def normalize
    year = self.start_date.year
    country_city = country || city.to_s.upcase.gsub(/\s+/, '_')

    matched_item = nil
    CompetitionNormalize.all.each do |item|
      if name.match?(/#{item.regex}/)
        matched_item = item
        break
      end
    end
    matched_item ||= CompetitionNormalize.new(competition_class: :unknow, competition_type: :unknow, short_name: name.to_s.gsub(/\s+/, '_'), name: name)

    hash = { year: year, city: city, country_city: country_city }

    self.competition_class ||= matched_item.competition_class.to_sym
    self.competition_type ||= matched_item.competition_type.to_sym
    self.short_name ||= matched_item.short_name % hash
    self.name = matched_item.name % hash if matched_item.name.present?
    self
  end
end
