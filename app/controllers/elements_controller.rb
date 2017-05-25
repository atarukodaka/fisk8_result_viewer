class ElementsListDecorator < ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end
end
################################################################
class ElementsController < ApplicationController  
  def filters
    @filteres ||= IndexFilters.new.tap {|f|
      f.filters = {
        element: {
          operator: (params[:perfect_match]) ? :eq : :like,
          input: :text_field, model: Element,
        },
        perfect_match: { operator: nil, input: :checkbox, },
        goe: { operator: :compare, input: :text_field, model: Element},
      }.merge score_filters.filters
    }
  end
  def display_keys
#    [:sid, :competition_name, :category, :segment, :date, :season,
    [:sid, :competition_name, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :element, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
  def collection
    Element.with_score.order("scores.date desc").joins(score: [:competition]).filter(filters.create_arel_tables(params)).select("scores.*, competitions.season, elements.*")
  end
end
