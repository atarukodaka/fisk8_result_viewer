class ScoreDecorator < EntryDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
  def name
    h.link_to_score(model.name, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
  def skater_name
    h.link_to_skater(model.skater)
  end
  def competition_name
    h.link_to_competition(model.competition)
  end
  def category
    h.link_to_competition(model.competition, category: model.category)
  end
  def segment
    h.link_to_competition(model.competition, category: model.category, segment: model.segment)
  end
  def elements_summary
    model.elements.map(&:name).join('/')
  end
  def components_summary
    model.components.map(&:value).join('/')
  end

end
