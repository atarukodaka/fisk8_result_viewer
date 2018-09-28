class DeviationDecorator < EntryDecorator
  def score_name
    h.link_to_score(model.score)
  end
  def category_name
    h.link_to_competition(model.score.competition, category: model.score.category)
  end
  def skater_name
    #h.link_to_skater(model.score.skater)
    h.link_to(model.score.skater_name, h.deviations_skater_path(model.score.skater_name))
  end
  def panel_name
    #h.link_to_panel(model.official.panel)
    h.link_to(model.official.panel_name, h.deviations_panel_path(model.official.panel_name))
  end

  def tes_deviation
    "%.02f" % [ model.tes_deviation || 0]
  end

  def pcs_deviation
    "%.02f" % [ model.pcs_deviation || 0]
  end
  
  def tes_deviation_ratio
    h.number_to_percentage(model.tes_deviation_ratio*100, precision: 2)
  end

  def pcs_deviation_ratio
    h.number_to_percentage(model.pcs_deviation_ratio*100, precision: 2)
  end
end
