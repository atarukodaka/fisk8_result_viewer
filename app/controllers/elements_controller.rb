class ElementDecorator < EntryDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end
  def element
    model.element
  end
end
################################################################
class ElementsController < ApplicationController  
  def filters
    @_filteres ||= IndexFilters.new.tap do |f|
      f.filters = {
        name: {
          operator: (params[:perfect_match]) ? :eq : :like,
          input: :text_field, model: Element,
        },
        perfect_match: { operator: nil, input: :checkbox, value: 'PERFECT_MATCH'},
        goe: { operator: :compare, input: :text_field, model: Element},
            
      }.merge score_filters.filters
    end
  end
  def display_keys
    [:sid, :competition_name, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
  def collection
    Element.with_score.recent.with_competition.filter(filters.create_arel_tables(params)).select("scores.*, competitions.season, elements.*")
  end
end
