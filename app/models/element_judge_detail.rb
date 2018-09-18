class ElementJudgeDetail < ApplicationRecord
  belongs_to :panel
  belongs_to :element

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
    panel.name
  end
  def goe
    element.goe
  end
end
