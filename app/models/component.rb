class Component < ApplicationRecord
  include ScoreVirtualAttributes
  
  ## relations
  belongs_to :score

  ## scopes
  scope :recent, ->{ joins(:score).order("scores.date desc") }
end

