class ElementDecorator < EntryDecorator
  class << self
    def column_names
      [:sid, :competition_name, :date, :season,
       :ranking, :skater_name, :nation,
       :number, :name, :credit, :info, :base_value, :goe, :judges, :value,
      ]
    end
  end
  def sid
    h.link_to_score(nil, model.score)
  end
  def ranking
    model.score.ranking
  end
  def element
    model.name
  end
  def competition_name
    model.score.competition_name
  end
  def date
    model.score.date
  end
  def season
    model.score.competition.season
  end
  def skater_name
    model.score.skater_name
  end
  def nation
    model.score.nation
  end
end
