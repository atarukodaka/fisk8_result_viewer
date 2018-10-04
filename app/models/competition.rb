class Competition < ApplicationRecord
  # before_save :normalize

  alias_attribute :competition_name, :name

  ## relations
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :performed_segments, dependent: :destroy

  ## validations
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/ }

  ## scopes
  scope :recent, -> { order('start_date desc') }

  ## updater
  def normalize
    year = self.start_date.year
    country_city = country || city.to_s.upcase.gsub(/\s+/, '_')

    ary = nil
    data = YAML.load_file(File.join(Rails.root.join('config'), 'competition_normalize.yml'))
    data.each do |key, value|
      # if name =~ Regexp.new(key) ## TODO: Regexp match to rewrite
      if name.match?(/#{key}/)
        ary = value
        break
      end
    end

    if ary.nil?
      ary = [:unknow, :unknow, name.to_s.gsub(/\s+/, '_')]
    end
    hash = { year: year, city: city, country_city: country_city }

    self.competition_class ||= ary[0].to_sym
    self.competition_type ||= ary[1].to_sym
    self.short_name ||= ary[2] % hash
    self.name = ary[3] % hash if ary[3]

    self
  end
end
