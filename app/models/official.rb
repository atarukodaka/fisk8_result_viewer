class Official < ApplicationRecord
  belongs_to :panel
  belongs_to :performed_segment

  def competition_name
    performed_segment.competition.name
  end
  def category
    performed_segment.category.name
  end

  def segment
    performed_segment.segment.name
  end

  def panel_name
    panel.name
  end

  def panel_nation
    panel.nation
  end

end
