class Score < ApplicationRecord
  before_save :set_score_name

  alias_attribute :score_name, :name

  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true
  has_many :deviations, dependent: :destroy

  belongs_to :competition

  ## # references
  belongs_to :skater
  belongs_to :category
  belongs_to :segment
  #belongs_to :performed_segment

  ## scopes
  scope :recent, -> { order('date desc') }
  scope :short, -> { joins(:segment).where(segments: { segment_type: :short }) }
  scope :free, -> { joins(:segment).where(segments: { segment_type:  :free }) }
  scope :category, ->(c) { where(category: c) }
  scope :segment, ->(s) { where(segment: s) }

  ## virtual attributes
  delegate :competition_name, :competition_key, :competition_class, :competition_subclass, :season, to: :competition
  delegate :skater_name, :nation, to: :skater
  delegate :category_name, :category_type, :seniority, :team, to: :category
  delegate :segment_name, :segment_type, to: :segment

  def category_type_name
    category.category_type.name
  end

  ## for statics
  [:SS, :TR, :PE, :CO, :IN].each_with_index do |key, i|
    define_method("component_#{key}") do
      components.try(:[], i).try(:value)
    end
  end

  ##
  def summary
    '    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d' %
      [category_name, segment_name, ranking,
       skater_name.truncate(35), skater.isu_number.to_i, nation,
       tss.to_f, tes.to_f, pcs.to_f, deductions.to_i]
  end

  private

  def set_score_name
    if name.blank?
      self.name = [competition.try(:key), category.abbr, segment.abbr, ranking].join('-')
    end
    self
  end
end
