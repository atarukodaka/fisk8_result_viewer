class PerformedSegment < ApplicationRecord
  has_many :scores
  validates  :starting_time, presence: true

  belongs_to :competition
  belongs_to :category
  belongs_to :segment

  belongs_to :judge01, class_name: "Panel", optional: true
  belongs_to :judge02, class_name: "Panel", optional: true
  belongs_to :judge03, class_name: "Panel", optional: true
  belongs_to :judge04, class_name: "Panel", optional: true
  belongs_to :judge05, class_name: "Panel", optional: true
  belongs_to :judge06, class_name: "Panel", optional: true
  belongs_to :judge07, class_name: "Panel", optional: true
  belongs_to :judge08, class_name: "Panel", optional: true
  belongs_to :judge09, class_name: "Panel", optional: true
  belongs_to :judge10, class_name: "Panel", optional: true
  belongs_to :judge11, class_name: "Panel", optional: true
  belongs_to :judge12, class_name: "Panel", optional: true
  
end
