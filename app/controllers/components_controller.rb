class ComponentsListDecorator < ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end
end
################################################################
class ComponentsController <  ApplicationController
  def filters
    f = score_filters
    f.attributes = {
      value: { operator: :compare, input: :text_field, model: Component},
    }
    f
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :component, :factor, :judges, :value]
  end

  def collection
    Component.with_score.order("scores.date desc").joins(score: [:competition]).filter(filters.create_arel_tables(params)).select("scores.*, competitions.season, components.*")
  end
end
