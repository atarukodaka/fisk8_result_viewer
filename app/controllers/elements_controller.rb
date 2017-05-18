class ElementsListDecorator < Draper::Decorator
  include ListDecorator
  def sid
    h.link_to(model.sid, controller: :scores, action: :show, sid: model.sid)
  end
end

class ElementsController < ApplicationController
  def index
    @filters = {
      element: {
        operator: (params[:partial_match]) ? :like : :eq,
        input: :text_field, model: Element,
      },
      partial_match: { operator: nil, input: :checkbox, },
      goe: { operator: :compare, input: :text_field, model: Element},
      skater_name: {operator: :like, input: :text_field, model: Score},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},
      season: { operator: :eq, input: :select, model: Competition},
    }

    keys = {
      scores: [:sid, :competition_name, :category, :segment, :date, :ranking, :skater_name, :nation],
      elements: [:number, :element, :credit, :info, :base_value, :goe, :judges, :value,],
      competitions: [:season],
    }
    ## something hack to insert competitions.season into middle of score's key
    @keys = keys[:scores].dup.insert(keys[:scores].index(:ranking), :season) + keys[:elements]
    #@keys = [:sid]
    ElementsListDecorator.set_filter_keys(@filters.keys)
    collection = Element.with_score.joins(score: [:competition]).filter(@filters, params).select_by_keys(keys)
    render_index_as_formats(collection, decorator: ElementsListDecorator)
  end
end
