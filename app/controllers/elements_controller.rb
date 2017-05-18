class ElementsListDecorator < Draper::Decorator
  include ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end
end

class ElementsController < ApplicationController
  def filters
    {
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
  end
  def select_keys
    {
      scores: [:sid, :competition_name, :category, :segment, :date, :ranking, :skater_name, :nation],
      elements: [:number, :element, :credit, :info, :base_value, :goe, :judges, :value, :score_id],
      competitions: [:season],
    }
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :element, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
  def index
    ElementsListDecorator.set_filter_keys(filters.keys)
    collection = Element.with_score.joins(score: [:competition]).filter(filters, params).select_by_keys(select_keys)
    
    render_index_as_formats(collection, filters: filters, display_keys: display_keys, decorator: ElementsListDecorator)
  end
end
