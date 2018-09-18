class PerformedSegment < ApplicationRecord
  has_many :scores
  has_many :officials, dependent: :destroy
  validates  :starting_time, presence: true

  belongs_to :competition
  belongs_to :category
  belongs_to :segment

  def competition_name
    competition.name
  end
end
