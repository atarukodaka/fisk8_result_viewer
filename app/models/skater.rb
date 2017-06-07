class Skater < ApplicationRecord
  has_many :category_results
  has_many :scores
  has_many :elements, through: :scores
  has_many :components, through: :scores
  
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}
  validates :isu_number, allow_nil: true, numericality:  { only_integer: true }

  scope :having_scores, ->{
    where(id: Score.select(:skater_id).group(:skater_id).having("count(skater_id)> ? ", 0))
  }
  #scope :search_by_name, ->(name){ where("name like ? ", "%#{name}%") }

  def highest_score
    category_results.pluck(:points).compact.max
  end
  def competitions_participated
    category_results.count
  end
  def gold_won
    category_results.where(ranking: 1).count
  end
  def highest_ranking
    category_results.pluck(:ranking).compact.reject {|d| d == 0}.min
  end

  def most_valuable_element
    elements.order(:value).last
  end
  def most_valuable_components
    components.group(:number).maximum(:value)
  end
end ## class Skater
