class JudgeDetailDecorator < EntryDecorator
  def score_name
    h.link_to_score(model.detailable.score)
  end

  def skater_name
    h.link_to_skater(model.detailable.score.skater)
  end

  def panel_name
    h.link_to_panel(official.panel)
  end
  decorate_as_score(:average, :deviation)
end
