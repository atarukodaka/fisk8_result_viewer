class Competition < ApplicationRecord
  before_save :_normalize

  alias_attribute :competition_name, :name

  ## relations
  has_many :performed_segments, dependent: :destroy
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/ }

  ## scopes
  scope :recent, -> { order('start_date desc') }


  private

  def _normalize
    matched_item = nil
    CompetitionNormalize.all.each do |item|    ## rubocop:disable Rails/FindEach
      if self.name.match?(item.regex)
        matched_item = item
        break
      end
    end
    matched_item ||= CompetitionNormalize.new(short_name: self.name.to_s.gsub(/\s+/, '_'))

    hash = { year: self.start_date.year, country: self.country, city: self.city }
    self.competition_class ||= matched_item.competition_class.to_sym
    self.competition_type ||= matched_item.competition_type.to_sym
    self.short_name ||= matched_item.short_name.to_s % hash
    self.name = matched_item.name % hash if matched_item.name.to_s.present?
    self.season = SkateSeason.new(self.start_date).season

    self           ## ensure to return self
  end
end
