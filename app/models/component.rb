class Component < ApplicationRecord
  include ScoreVirtualAttributes
  
  ## relations
  has_many :component_judge_details, dependent: :destroy
  belongs_to :score

  ## scopes
  scope :recent, ->{ joins(:score).order("scores.date desc") }
end

