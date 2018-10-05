class ElementJudgeDetail < ApplicationRecord
  belongs_to :official
  belongs_to :element

  def self.enabled?
    (self.positive?) ? true : false
  end

  ## virtual attributes
  delegate :score_name, to: :element
  delegate :panel_name, to: :official
  delegate :number, to: :element, prefix: :element
  delegate :name, to: :element, prefix: :element
  delegate :goe, to: :element

  def skater_name
    element.score.skater_name
  end
end
