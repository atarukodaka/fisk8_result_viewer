class OfficialDecorator < EntryDecorator
  def competition_name
    h.link_to_competition(model.competition)
  end

  def category_name
    h.link_to_competition(competition, category: category)
  end

  def segment_name
    h.link_to_competition(competition, category: category, segment: segment)
  end

  def panel_name
    h.link_to_panel(model.panel)
  end
end
