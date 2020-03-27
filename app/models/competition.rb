class Competition < ApplicationRecord
  before_save :_before_save  # normalize

  alias_attribute :competition_name, :name
  alias_attribute :competition_key, :key

  ## relations
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :time_schedules, dependent: :destroy
  has_many :officials, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/ }

  ## scopes
  scope :recent, -> { order('start_date desc') }

  private

  def _normalize
    if self.key.nil?
      self.key = self.name.to_s.upcase.gsub(/\s+/, '_')
    elsif (item = CompetitionNormalize.find_match(self.key))
      hash = { year: self.start_date.year, country: self.country, city: self.city }
      self.name = item.name % hash if item.name

      self.competition_class = item.competition_class
      self.competition_type = item.competition_type
    end
  end

  def _before_save
    _normalize
    self.season ||= SkateSeason.new(self.start_date).season if self.start_date

    self           ## ensure to return self

  end

end
