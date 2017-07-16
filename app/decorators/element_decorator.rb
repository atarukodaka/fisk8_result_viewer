class ElementDecorator < EntryDecorator
  using AsScore
  
  def score_name
    h.link_to_score(nil, model.score)
  end
  def ranking
    h.link_to_competition(model.score.ranking, model.score.competition, category: model.score.category, segment: model.score.segment)
  end
  def competition_name
    h.link_to_competition(model.score.competition)
  end
  def skater_name
    h.link_to_skater(model.score.skater)
  end
  def description
    "%s %s%s (%.2f=%.2f+%.2f)" % [ model.name, model.credit, model.info, model.value, model.base_value, model.goe]
  end
  def base_value
    model.base_value.as_score
  end
  def goe
    model.goe.as_score
  end
  def value
    model.value.as_score
  end
end
