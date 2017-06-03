class ElementDecorator < EntryDecorator
  def sid
    h.link_to_score(nil, model.score)
  end
  def ranking
    model.score.ranking
  end
  def element
    model.name
  end
  def competition_name
    model.score.competition_name
  end
  def date
    model.score.date
  end
  def season
    model.score.competition.season
  end
  def skater_name
    model.score.skater_name
  end
  def nation
    model.score.nation
  end
end
################################################################
class ElementsController < ApplicationController
  def filters
    {
      name: ->(col, v) {
        if params[:perfect_match]
          col.where("elements.name" => v)
        else
          col.where("elements.name like ? ", "%#{v}%")
        end
      },
      goe: ->(col, v){
        arel = create_arel_table_by_operator(Element, :goe, params[:goe_operator], v)
        col.where(arel)
      }
    }.merge(score_filters)
=begin
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
=end
  end
  def display_keys
    [:sid, :competition_name, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :credit, :info, :base_value, :goe, :judges, :value,
    ]
  end
  def collection
    filter(Element.includes(:score, score: [:competition]))    #.filter(filters.create_arel_tables(params)).select("scores.*, competitions.season, elements.*")
  end
end
