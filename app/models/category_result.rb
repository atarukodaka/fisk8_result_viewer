class CategoryResult < ApplicationRecord
  ## relations
  # has_many :scores

  belongs_to :competition
  belongs_to :skater
  belongs_to :short, class_name: 'Score', optional: true
  belongs_to :free, class_name: 'Score', optional: true
  belongs_to :category

  ## virtual attributes
  delegate :competition_name, to: :competition
  delegate :skater_name, :nation, to: :skater
  #delegate :tss, :tes, :pcs, :deductions, :base_value, to: :short, prefix: :short, allow_nil: true
  #delegate :tss, :tes, :pcs, :deductions, :base_value, to: :free, prefix: :free, allow_nil: true

  def date
    competition.start_date
  end

  ## scopes
  scope :recent, -> { joins(:competition).order('competitions.start_date desc') }
  scope :category, ->(cat) { where(category: cat) }
  scope :segment_ranking, ->(segment, ranking) { where("#{segment.segment_type}_ranking": ranking) }
  scope :qualified, -> { where.not(ranking: 0) }

  def summary
    '  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d' %
      [self.category.name, self.ranking.to_i, self.skater.name.truncate(35),
       self.skater.isu_number.to_i, self.skater.nation, self.points.to_f,
       self.short_ranking.to_i, self.free_ranking.to_i]
  end
end
