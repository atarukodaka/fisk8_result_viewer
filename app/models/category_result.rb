class CategoryResult < ApplicationRecord
  ## relations
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater
  
  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }
  scope :top_rankers, ->(n) { where("ranking > 0 and ranking <= ? ", n.to_i).order(:ranking) }

  class << self
    def highest_score
      pluck(:points).compact.max
    end
    def highest_ranking
      pluck(:ranking).compact.reject {|d| d == 0}.min
    end
  end
end
