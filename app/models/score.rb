class Score < ApplicationRecord
  before_save :set_score_name
  
  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, optional: true
  #belongs_to :performed_segment, required: false

  ## virtual attributes
  def competition_name
    competition.name
  end
  def competition_class
    competition.competition_class
  end
  def competition_type
    competition.competition_type
  end
  def season
    competition.season
  end
  def skater_name
    skater.name
  end
  def nation
    skater.nation
  end

  ## scopes
  scope :recent, ->{ order("date desc") }
  scope :short, -> { where("segment like ? ", "%SHORT%") }
  scope :free, ->  { where("segment like ? ", "%FREE%") }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(s){ where(segment: s) }

  ##
  def summary
    skater_name = self.skater.try(:name) || self.skater_name
    nation = self.skater.try(:nation) || self.nation
    isu_number = self.skater.try(:isu_number) || 0

    "    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d" % [self.category, self.segment, self.ranking, skater_name.truncate(35), isu_number.to_i, nation, self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end

  private
  def set_score_name
    segment_type = (segment =~ /SHORT/) ? :short : :free
    if name.blank?
      category_abbr = Category.find_by(name: category).try(:abbr)
      segment_abbr = segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'

      self.name = [competition.try(:short_name), category_abbr, segment_abbr, ranking].join('-')
    end
    self
  end
end

