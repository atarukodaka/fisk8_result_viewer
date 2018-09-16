class PerformedSegment < ApplicationRecord
  has_many :scores
  validates  :starting_time, presence: true

  belongs_to :competition
  belongs_to :category
  belongs_to :segment
end
