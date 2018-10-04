class ElementJudgeDetailDecorator < EntryDecorator
  def score_name
    h.link_to_score(model.element.score)
  end

  def skater_name
    h.link_to_skater(model.element.score.skater)
  end

  def panel_name
    h.link_to_panel(official.panel)
  end
  decorate_as_score(:average)
end
