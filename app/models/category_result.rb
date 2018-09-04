class CategoryResult < ApplicationRecord
  ## relations
  #has_many :scores
  
  belongs_to :competition
  belongs_to :skater

  belongs_to :short, class_name: "Score", optional: true  # required: true on default. see https://github.com/rails/rails/issues/18233
  belongs_to :free, class_name: "Score", optional: true
  
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

=begin
  def short
    scores.first || Score.new  ## segment =~ /SHORT/
    #scores.where("scores.segment like ?", 'SHORT%').first
  end
  def free
    #scores.where("scores.segment like ?", 'FREE%').first
    scores.second || Score.new
  end
=end
  ################
=begin
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
=end
  [:tss, :tes, :pcs, :deductions, :base_value].each do |key|
    define_method("short_#{key}".to_sym) do
      short.send(key)
    end
    define_method("free_#{key}".to_sym) do
      free.send(key)
    end
  end

  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }

  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking.to_i, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end
end
