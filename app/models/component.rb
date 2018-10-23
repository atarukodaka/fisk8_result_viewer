class Component < ApplicationRecord
  include ScoreVirtualAttributes

  alias_attribute :component_name, :name
  alias_attribute :component_number, :number

  ## relations
  has_many :component_judge_details, dependent: :destroy
  belongs_to :score

  ## scopes
  scope :recent, -> { joins(:score).order('scores.date desc') }
end
