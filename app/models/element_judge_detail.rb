class ElementJudgeDetail < ApplicationRecord
  belongs_to :official
  belongs_to :element

  def self.enabled?
      (self.count > 0) ? true : false
  end

  ## virtual attributes
  def score_name
    element.score.name
  end
  def skater_name
    element.score.skater.name
  end
  def panel_name
    official.panel.name
  end
  delegate :number, to: :element, prefix: :element
  delegate :name, to: :element, prefix: :element
  delegate :goe, to: :element
end
