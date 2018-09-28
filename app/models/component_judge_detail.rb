class ComponentJudgeDetail < ApplicationRecord
  belongs_to :official
  belongs_to :component

  def self.enabled?
      (self.count > 0) ? true : false
  end

  ## virtual attributes
  delegate :score_name, to: :element
  delegate :panel_name, to: :official
  delegate :number, to: :component, prefix: :component
  delegate :name, to: :component, prefix: :component

  def skater_name
    component.score.skater_name
  end

=begin
  def score_name
    component.score.name
  end
  def component_name
    component.name
  end
  def panel_name
    official.panel.name
  end
=end
end
