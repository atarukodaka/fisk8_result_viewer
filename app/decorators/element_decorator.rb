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
=begin
  def category
    model.category.name
  end
  def segment
    model.segment.name
  end
=end
  def skater_name
    h.link_to_skater(model.score.skater)
  end
=begin
  def description
    "%s %s%s (%.2f=%.2f+%.2f)" % [ model.name, model.credit, model.info, model.value, model.base_value, model.goe]
  end
=end
  decorate_as_score(:base_value, :goe, :value, :level)
  decorate_as_score(:avg_value, :avg_base_value, :avg_goe, :avg_level)  
end
