class ElementsListDecorator < ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end
end
################################################################
class ElementsController < ApplicationController  
  def filters
    f = score_filters
    f.attributes = {
      element: {
        operator: (params[:partial_match]) ? :like : :eq,
        input: :text_field, model: Element,
      },
      partial_match: { operator: nil, input: :checkbox, },
      goe: { operator: :compare, input: :text_field, model: Element},
    }
    f
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :element, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
  def collection
    Element.with_score.order("scores.date desc").joins(score: [:competition]).filter(filters.create_arel_tables(params)).select("scores.*, competitions.season, elements.*")
  end
end
