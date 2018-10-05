class Score < ApplicationRecord
  before_save :set_score_name

  alias_attribute :score_name, :name

  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true

  belongs_to :category
  belongs_to :segment
  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, optional: true
  belongs_to :performed_segment, optional: true

  ## scopes
  scope :recent, -> { order('date desc') }
  scope :short, -> { joins(:segment).where(segments: { segment_type: :short }) }
  scope :free, -> { joins(:segment).where(segments: { segment_type:  :free }) }
  scope :category, ->(c) { where(category: c) }
  scope :segment, ->(s) { where(segment: s) }

  ## virtual attributes
  {
    competition: [:competition_name, :short_name, :competition_class, :competition_type, :season],
    skater:      [:skater_name, :nation],
    category:    [:category_name, :category_type, :seniority, :team],
    segment:     [:segment_name, :segment_type],
  }.each do |model, ary|
    ary.each do |key|
      delegate key, to: model
    end
  end
  delegate :segment_type, to: :segment

  ## for statics
  [:SS, :TR, :PE, :CO, :IN].each_with_index do |key, i|
    define_method("component_#{key}") do
      components.try(:[], i).try(:value)
    end
  end

  ##
  def summary
    skater_name = self.skater.try(:name) || self.skater_name
    nation = self.skater.try(:nation) || self.nation
    isu_number = self.skater.try(:isu_number) || 0

    '    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d' %
      [self.category.name, self.segment.name, self.ranking,
       skater_name.truncate(35), isu_number.to_i, nation,
       self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end

  private

  def set_score_name
    if name.blank?
      self.name = [competition.try(:short_name), category.abbr, segment.abbr, ranking].join('-')
    end
    self
  end
end
