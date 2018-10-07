class ElementJudgeDetail < ApplicationRecord
  belongs_to :element

  ## references
  belongs_to :official

  ## virtual attributes
  delegate :score_name, :goe, to: :element
  delegate :panel_name, to: :official
  delegate :name, :number, to: :element, prefix: :element
  delegate :skater_name, to: :score
end
