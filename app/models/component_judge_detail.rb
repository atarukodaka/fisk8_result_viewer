class ComponentJudgeDetail < ApplicationRecord
  belongs_to :component

  ## references
  belongs_to :official

  ## virtual attributes
  delegate :score_name, to: :element
  delegate :panel_name, to: :official
  delegate :name, :number, to: :component, prefix: :component
  delegate :skater_name, to: :score

  ## scope
  #scope :valid, -> { joins(:official).where("officials.absence": false) }
end
