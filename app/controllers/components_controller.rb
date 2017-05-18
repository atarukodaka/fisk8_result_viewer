class ComponentsListDecorator < Draper::Decorator
  include ListDecorator
  def sid
    h.link_to(model.sid, controller: :scores, action: :show, sid: model.sid)
  end

end
################################################################
class ComponentsController < ApplicationController
  def index
    @filters = {
      skater_name: {operator: :like, input: :text_field, model: Score},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},
      value: {operator: :compare, input: :text_field, model: Component},
    }

    keys = {
    scores: [:sid, :competition_name, :category, :segment, :date, :ranking, :skater_name, :nation],
      components: [:number, :component, :factor, :judges, :value]
    }
    @keys = keys.values.flatten
    ComponentsListDecorator.set_filter_keys(@filters.keys)
    collection = Component.with_score.filter(@filters, params).select_by_keys(keys)
    render_index_as_formats(collection, decorator: ComponentsListDecorator)
  end
end
