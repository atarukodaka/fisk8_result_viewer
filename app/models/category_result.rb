class CategoryResult < ApplicationRecord
  include IsuChampionshipsOnly
  
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater
  
  ## scope
  scope :with_competition, ->{ joins(:competition) }
  scope :recent, ->{ with_competition.order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }
  scope :top_rankers, ->(n) { where("ranking > 0 and ranking <= ? ", n.to_i).order(:ranking) }
end
