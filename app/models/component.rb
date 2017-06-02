class Component < ApplicationRecord
  include IsuChampionshipsOnly
  
  belongs_to :score

  scope :recent, ->{ with_score.order("scores.date desc") }
  scope :with_competition, ->{ joins(score: [:competition]) }
end

