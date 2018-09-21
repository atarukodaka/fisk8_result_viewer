class ComponentJudgeDetail < ApplicationRecord
  belongs_to :official
  belongs_to :component

  ## virtual attributes
  def score_name
    component.score.name
  end
  def skater_name
    component.score.skater.name
  end
  def component_name
    component.name
  end
  def panel_name
    official.panel.name
  end
end
