class ComponentJudgeDetail < ApplicationRecord
  belongs_to :official
  belongs_to :component

  ## virtual attributes
  def score_name
    element.score.name
  end
  def skater_name
    element.score.skater.name
  end
  def element_name
    element.name
  end
  def panel_name
    official.panel.name
  end
  def goe
    element.goe
  end
end
