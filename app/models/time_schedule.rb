class TimeSchedule < ApplicationRecord
  # has_many :scores, dependent: :nullify
  belongs_to :competition
  belongs_to :category
  belongs_to :segment

  delegate :competition_name, to: :competition
  delegate :category_name, to: :category
  delegate :segment_name, to: :segment

  validates :starting_time, presence: true
end
