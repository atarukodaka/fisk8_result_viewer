class ComponentDecorator < EntryDecorator
  class << self
    def column_names
      [:sid, :competition_name, :date, :season, :ranking, :skater_name, :nation,
       :number, :name, :factor, :judges, :value]
    end
  end
  def sid
    h.link_to_score(nil, model.score)
  end
  def component
    model.component
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
################################################################
class ComponentsController <  ApplicationController
  def filters
    {
      value: ->(col, v){
        arel = create_arel_table_by_operator(Component, :value, params[:value_operator], v)
        col.where(arel)
      }

    }.merge(score_filters)
  end
  def collection
    filter(Component.includes(:score, [score: [:competition, :skater]])) 
  end
end
