class Panel < ApplicationRecord
  has_many :element_judge_details
  has_many :component_judge_details
  has_many :scores
end
