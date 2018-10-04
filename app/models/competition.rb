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

=begin
    ary = case name
          when /Grand Prix .*Final/, /^ISU GP.*Final/
            [:isu, :gp, "GPF#{year}"]
          when /^ISU GP/
            [:isu, :gp, "GP#{country_city}#{year}"]
          when /Olympic/
            [:isu, :olympic, "OWG#{year}", "Olympic Winter Games #{city} #{year}"]
          when /^ISU World Figure/, /^ISU World Championships/
            [:isu, :world, "WORLD#{year}", "ISU World Championships #{year}"]
          when /^ISU Four Continents/
            [:isu, :fcc, "FCC#{year}", "ISU Four Continents Championships #{year}"]
          when /^ISU European/
            [:isu, :euro, "EURO#{year}", "ISU European Championships #{year}"]
          when /^ISU World Team/
            [:isu, :team, "TEAM#{year}", "ISU World Team Trophy #{year}"]
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
            [:unknown, :unknown, name.to_s.gsub(/\s+/, '_')]
          end
=end

    ary = nil
    data = YAML.load_file(File.join(Rails.root.join('config'), 'competition_normalize.yml'))
    data.each do |key, value|
      if name =~ Regexp.new(key)
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
