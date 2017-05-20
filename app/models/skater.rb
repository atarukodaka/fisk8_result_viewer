class Skater < ApplicationRecord
  has_many :category_results
  has_many :scores
  #validates :name, presence: true

  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}
  #validates :category, presence: true
  validates :isu_number, allow_nil: true, numericality:  { only_integer: true }

  scope :having_scores, ->{
    where(id: Score.select(:skater_id).group(:skater_id).having("count(skater_id)> ? ", 0))
  }
  

  class << self
    def select_options(key)
      case key
      when :category
        [nil, :MEN, :LADIES, :PAIRS, :"ICE DANCE"]
      else
        super(key)
      end
    end
  end
  
end ## class Skater
