class Score < ApplicationRecord
  before_save :set_score_name  #, :set_skater_name
  
  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, required: false

  ## validations
  validates  :date, presence: true

  ## scopes
  scope :recent, ->{ order("date desc") }
  scope :short, -> { matches(:segment, "SHORT") }
  scope :free, -> { matches(:segment, "FREE") }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(c, s){ category(c).where(segment: s) }

  def summary
    skater_name = self.skater.try(:name) || self.skater_name
    nation = self.skater.try(:nation) || self.nation
    isu_number = self.skater.try(:isu_number) || 0
    
    "    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d" % [self.category, self.segment, self.ranking, skater_name.truncate(35), isu_number.to_i, nation, self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end

=begin
  def to_s
    str = "-" * 100 + "\n"
    str << "%<ranking>d %<skater_name>s [%<nation>s] %<starting_number>d  %<tss>6.2f = %<tes>6.2f + %<pcs>6.2f + %<deductions>2d\n" % self.attributes.symbolize_keys
    str << "Executed Elements\n"
    str << self.elements.map do |element|
      "  %<number>2d %<name>-20s %<info>-3s %<base_value>5.2f %<goe>5.2f %<judges>-30s %<value>6.2f" % element.attributes.symbolize_keys.merge(judges: element[:judges].split(/\s/).map {|v| "%4s" % [v]}.join(' '))

    end.join("\n")
    str << "\nProgram Components\n"
    str << self.components.map do |component|
      "  %<number>d %<name>-31s %<factor>3.2f %<judges>-15s %<value>6.2f" % component.attributes.symbolize_keys
    end.join("\n")
    if self[:deduction_reasons]
      str << "\nDeductions\n  " + self[:deduction_reasons] << "\n"
    end
    str
  end
=end
  private
  def set_score_name
    return if self[:name].present?
    category_abbr = self.category || ""
    [["MEN", "M"], ["LADIES", "L"], ["PAIRS", "P"], ["ICE DANCE", "D"],
     ["JUNIOR ", "J"]].each do |ary|
      key, abbr = ary
      category_abbr = category_abbr.gsub(key, abbr)
    end

    segment_abbr = self.segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'

    self[:name] = [self.competition.try(:short_name), category_abbr, segment_abbr, self.ranking].join('-')
    self
  end
=begin
  def set_skater_name
    self[:skater_name] = skater.name if self.skater
    self
  end
=end
end

