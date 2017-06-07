class Component < ApplicationRecord
  include IsuChampionshipsOnly
  
  belongs_to :score

  scope :recent, ->{ joins(:score).order("scores.date desc") }
end

