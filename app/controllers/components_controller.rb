class CompetitionListDecorator < Draper::Decorator
  include ListDecorator

  set_filter_keys(:nation, :category)
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to(model.isu_number, isu_bio_url(model.isu_number))
  end
end


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

    collection = Component.with_score.filter(@filters, params).select_by_keys(keys)
    render_formats(collection, page: params[:page])
  end
end
