class OfficialDecorator < EntryDecorator
  def competition_name
    h.link_to_competition(model.performed_segment.competition)
  end

  def category
    h.link_to_competition(model.performed_segment.competition, category: model.performed_segment.category)
  end
  def segment
    h.link_to_competition(model.performed_segment.competition, category: model.performed_segment.category, segment: model.performed_segment.segment)
  end
  def panel_name
    h.link_to_panel(model.panel)
  end
end
