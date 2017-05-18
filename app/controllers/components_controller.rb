class ComponentsListDecorator < Draper::Decorator
  include ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end

end
################################################################
class ComponentsController < ApplicationController
  def index
    filters = {
      skater_name: {operator: :like, input: :text_field, model: Score},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},
      value: {operator: :compare, input: :text_field, model: Component},
    }

    select_keys = {
      scores: [:sid, :competition_name, :category, :segment, :date, :ranking, :skater_name, :nation, ],
      components: [:number, :component, :factor, :judges, :value, :score_id],
      competitions: [:season],
    }
    display_keys = [:sid, :competition_name, :category, :segment, :date, :season,
                    :ranking, :skater_name, :nation,
                    :number, :component, :factor, :judges, :value]

    ComponentsListDecorator.set_filter_keys(filters.keys)
    collection = Component.with_score.joins(score: [:competition]).filter(filters, params).select_by_keys(select_keys)

    render_index_as_formats(collection, filters: filters, display_keys: display_keys, decorator: ComponentsListDecorator)
  end
end
