class ElementsDecorator < EntriesDecorator
  def column_names
    [:sid, :competition_name, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
end

################################################################
class ElementDecorator < EntryDecorator
  def sid
    h.link_to_score(nil, model.score)
  end
  def ranking
    model.score.ranking
  end
  def competition_name
    model.score.competition.name
  end
  def date
    model.score.date
  end
  def season
    model.score.competition.season
  end
  def skater_name
    model.score.skater.name
  end
  def nation
    model.score.skater.nation
  end
end
