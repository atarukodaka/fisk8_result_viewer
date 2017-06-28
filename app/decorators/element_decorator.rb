class ElementsDecorator < EntriesDecorator
  def column_names
    [:score_name, :competition_name, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
end

################################################################
class ElementDecorator < EntryDecorator
  def score_name
    h.link_to_score(nil, model.score)
  end
  def ranking
    h.link_to_competition(model.score.ranking, model.score.competition, category: model.score.category, segment: model.score.segment)
  end
  def competition_name
    h.link_to_competition(model.score.competition)
  end
  def date
    model.score.date
  end
  def season
    model.score.competition.season
  end
  def skater_name
    h.link_to_skater(model.score.skater)
  end
  def nation
    model.score.skater.nation
  end
  def description
    "%s %s%s (%.2f=%.2f+%.2f)" % [ model.name, model.credit, model.info, model.value, model.base_value, model.goe]
  end
end
