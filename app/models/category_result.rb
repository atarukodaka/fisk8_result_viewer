class CategoryResult < ApplicationRecord
  ## relations
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater

  ## virtual attributes
  def competition_name
    competition.name
  end
  def competition_short_name
    competition.short_name
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
  def date
    competition.start_date
  end
  def short
    scores.first   ## segment =~ /SHORT/
    #scores.where("scores.segment like ?", 'SHORT%').first
  end
  def free
    #scores.where("scores.segment like ?", 'FREE%').first
    scores.second
  end
  ################
  def short_tss
    short.try(:tss)
  end
  def short_tes
    short.try(:tes)
  end
  def short_pcs
    short.try(:pcs)
  end
  def short_deductions
    short.try(:deductions)
  end
  def short_bv
    short.try(:base_value)
  end
  def free_tss
    free.try(:tss)
  end
  def free_tes
    free.try(:tes)
  end
  def free_pcs
    free.try(:pcs)
  end
  def free_deductions
    free.try(:deductions)
  end
  def free_bv
    free.try(:base_value)
  end

  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }

  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking.to_i, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end
end
