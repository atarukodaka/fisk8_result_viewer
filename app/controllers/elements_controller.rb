class ElementsListDecorator < ListDecorator
  def sid
    ary = model.sid.split('/')
    text = [ary.shift, ary.map {|d| d[0]}].join('/')
    h.link_to_score(text, model.sid)
  end
end
################################################################
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
  def collection
    Element.with_score.joins(score: [:competition]).filter(filters, params).select("scores.*, competitions.season, elements.*")
  end
end
