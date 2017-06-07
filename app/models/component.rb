class Component < ApplicationRecord
  include IsuChampionshipsOnly

  ## relations
  belongs_to :score

  ## scopes
  scope :recent, ->{ joins(:score).order("scores.date desc") }
end

