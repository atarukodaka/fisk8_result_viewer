class ComponentsListDecorator < ListDecorator
  def sid
    ary = model.sid.split('/')
    text = [ary.shift, ary.map {|d| d[0]}].join('/')
    h.link_to_score(text, model.sid)
  end
end
################################################################
class ComponentsController <  ApplicationController
  def filters
    {
      value: { operator: :compare, input: :text_field, model: Component},
    }.merge(score_filters)
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :component, :factor, :judges, :value]
  end

  def collection
    Component.with_score.joins(score: [:competition]).filter(filters, params).select("scores.*, competitions.season, components.*")
  end
end
