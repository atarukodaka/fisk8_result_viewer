class DeviationDecorator < EntryDecorator
  def score_name
    h.link_to_score(model.score)
  end
  def skater_name
    h.link_to_skater(model.score.skater)
  end
  def panel_name
    h.link_to_panel(model.panel)
  end

  def tes_deviation
    "%.02f" % [ model.tes_deviation ]
  end

  def pcs_deviation
    "%.02f" % [ model.pcs_deviation ]
  end
  
  def tes_ratio
    h.number_to_percentage(model.tes_ratio*100, precision: 2)
  end

  def pcs_ratio
    h.number_to_percentage(model.pcs_ratio*100, precision: 2)
  end
end
