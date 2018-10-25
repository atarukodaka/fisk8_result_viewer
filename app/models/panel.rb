class Panel < ApplicationRecord
  has_many :officials, dependent: :nullify
  # has_many :element_judge_details, through: :official, dependent: :nullify
  # has_many :component_judge_details, through: :official, dependent: :nullify

  alias_attribute :panel_name, :name
  alias_attribute :panel_nation, :nation
end
