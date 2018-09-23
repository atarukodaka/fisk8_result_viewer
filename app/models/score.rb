class Score < ApplicationRecord
  before_save :set_score_name
  
  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true

  belongs_to :category
  belongs_to :segment
  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, optional: true
  #belongs_to :performed_segment, required: false

  ## virtual attributes
  [:competition_name, :short_name, :competition_class, :competition_type, :season].each do |key|
    delegate key, to: :competition
  end
  [:skater_name, :nation].each do |key|
    delegate key, to: :skater
  end
  [:category_name, :category_type, :seniority, :team].each do |key|
    delegate key, to: :category
  end
  delegate :segment_type, to: :segment

  ## for statics
  def component_SS
    components.try(:[], 0).try(:value)
  end
  def component_TR
    components.try(:[], 1).try(:value)
  end
  def component_PE
    components.try(:[], 2).try(:value)
  end
  def component_CO
    components.try(:[], 3).try(:value)
  end
  def component_IN
    components.try(:[], 4).try(:value)
  end

  ## scopes
  scope :recent, ->{ order("date desc") }
  scope :short, -> { joins(:segment).where(segments: {segment_type: :short}) }
  scope :free, -> { joins(:segment).where(segments: { segment_type:  :free}) }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(s){ where(segment: s) }

  ##
  def summary
    skater_name = self.skater.try(:name) || self.skater_name
    nation = self.skater.try(:nation) || self.nation
    isu_number = self.skater.try(:isu_number) || 0

    "    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d" % [self.category.name, self.segment.name, self.ranking, skater_name.truncate(35), isu_number.to_i, nation, self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end

  private
  def set_score_name
    #segment_type = (segment =~ /SHORT/) ? :short : :free
    if name.blank?
      #category_abbr = Category.find_by(name: category).try(:abbr)
      #segment_abbr = segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'

      self.name = [competition.try(:short_name), category.abbr, segment.abbr, ranking].join('-')
    end
    self
  end
end

