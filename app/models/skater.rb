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
  scope :search_by_name, ->(name){ where("name like ? ", "%#{name}%") }
  
end ## class Skater
