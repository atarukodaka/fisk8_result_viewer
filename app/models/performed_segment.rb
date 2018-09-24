class PerformedSegment < ApplicationRecord
  has_many :scores
  validates  :starting_time, presence: true

  belongs_to :competition
  belongs_to :category
  belongs_to :segment

  delegate :category_name, to: :category
  delegate :segment_name, to: :segment
end
