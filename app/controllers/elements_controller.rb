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
    }.merge(score_filters)
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :element, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
  def select_keys
    {
      scores: [:sid, :competition_name, :category, :segment, :date, :ranking, :skater_name, :nation],
      competitions: [:season],
      elements: [:number, :element, :credit, :info, :base_value, :goe, :judges, :value, :score_id],
    }
  end
  def collection
    Element.with_score.joins(score: [:competition]).filter(filters, params).select_by_keys(select_keys)
  end
end
