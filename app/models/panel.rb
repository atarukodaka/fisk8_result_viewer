class Panel < ApplicationRecord
  has_many :officials, dependent: :nullify
  has_many :element_judge_details, dependent: :nullify
  has_many :component_judge_details, dependent: :nullify
end
