class OfficialDecorator < EntryDecorator
  def competition_name
    h.link_to_competition(model.performed_segment.competition)
  end

  def category_name
    ps = model.performed_segment
    h.link_to_competition(ps.competition, category: ps.category)
  end
  def segment_name
    ps = model.performed_segment
    h.link_to_competition(ps.competition, category: ps.category, segment: ps.segment)
  end
  def panel_name
    h.link_to_panel(model.panel)
  end
end
