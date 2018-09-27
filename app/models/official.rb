class Official < ApplicationRecord
  belongs_to :panel
  belongs_to :performed_segment

  delegate :competition_name, to: :performed_segment
  delegate :category_name, to: :performed_segment
  delegate :segment_name, to: :performed_segment
  delegate :name, to: :panel, prefix: :panel
  delegate :nation, to: :panel, prefix: :panel
=begin  
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
=end
end
