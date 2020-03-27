class Competition < ApplicationRecord
  before_save :_normalize

  alias_attribute :competition_name, :name
  alias_attribute :competition_key, :key

  ## relations
  #has_many :performed_segments, dependent: :destroy
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
    if self.key
      matched_item = nil
      CompetitionNormalize.all.each do |item|    ## rubocop:disable Rails/FindEach
        if self.key.to_s.match?(item.regex)
          hash = { year: self.start_date.year, country: self.country, city: self.city }
          self.competition_class = item.competition_class
          self.competition_type = item.competition_type
          self.name = item.name % hash
          break
        end
      end
    else
      self.key = self.name.to_s.upcase.gsub(/\s+/, '_')
    end

    self.competition_class ||= 'unknown'
    self.competition_type ||= 'unknown'

    self.season ||= SkateSeason.new(self.start_date).season if self.start_date

    self           ## ensure to return self

  end

end
