class CategoryResult < ApplicationRecord
  ## relations
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater
  
  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }
  scope :top_rankers, ->(n) { where("ranking > 0 and ranking <= ? ", n.to_i).order(:ranking) }

  def summary
    "  %s %2d %-40s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking, self.skater.name, self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end

  class << self
    def highest_score
      pluck(:points).compact.max
    end
    def highest_ranking
      pluck(:ranking).compact.reject {|d| d == 0}.min
    end
  end
end
