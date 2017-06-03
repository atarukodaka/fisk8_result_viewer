class ComponentDecorator < EntryDecorator
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
################################################################
class ComponentsController <  ApplicationController
  def filters
    {
      value: ->(col, v){
        arel = create_arel_table_by_operator(Component, :value, params[:value_operator], v)
        col.where(arel)
      }

    }.merge(score_filters)
    
=begin
    @_filters ||= IndexFilters.new.tap do |f|
      f.filters = {
        value: {operator: :compare, input: :text_field, model: Component},
      }.merge score_filters.filters
    end
=end
  end
  def display_keys
#    [:sid, :competition_name, :category, :segment, :date, :season,
    [:sid, :competition_name, :date, :season,
    :ranking, :skater_name, :nation,
     :number, :name, :factor, :judges, :value]
  end

  def collection
    filter(Component.includes(:score, [score: :competition]))    #er(filters.create_arel_tables(params)).select("scores.*, competitions.season, components.*")
  end
end
