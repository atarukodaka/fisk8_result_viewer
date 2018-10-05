class ComponentJudgeDetail < ApplicationRecord
  belongs_to :official
  belongs_to :component

  def self.enabled?
    self.positive?
  end

  ## virtual attributes
  delegate :score_name, to: :element
  delegate :panel_name, to: :official
  delegate :number, to: :component, prefix: :component
  delegate :name, to: :component, prefix: :component

  def skater_name
    component.score.skater_name
  end
end
