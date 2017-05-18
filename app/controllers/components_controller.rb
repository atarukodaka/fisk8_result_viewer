class ComponentsListDecorator < Draper::Decorator
  include ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end

end
################################################################
class ComponentsController <  ApplicationController
  def filters
    score_filters
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :component, :factor, :judges, :value]
  end

  def collection
    Component.with_score.joins(score: [:competition]).filter(filters, params).select_by_keys(select_keys)
  end
  def select_keys
    {
      scores: [:sid, :competition_name, :category, :segment, :date, :ranking, :skater_name, :nation, ],
      components: [:number, :component, :factor, :judges, :value, :score_id],
      competitions: [:season],
    }
  end
  def index
    decorator = ComponentsListDecorator

    decorator.set_filter_keys(filters.keys)
    render_index_as_formats(collection, filters: filters, display_keys: display_keys, decorator: decorator)
  end
end
