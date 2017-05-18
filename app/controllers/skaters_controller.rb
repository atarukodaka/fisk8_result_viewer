class SkatersListDecorator < Draper::Decorator
  include ListDecorator

  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.content_tag(:span) do
      h.concat(h.link_to(model.isu_number, isu_bio_url(model.isu_number), target: "_blank"))
      h.concat(h.span_link_icon)      
    end
  end
end
class SkaterScoresListDecorator < Draper::Decorator
  include ListDecorator
  def competition_name
    h.link_to_competition(nil, model.competition)
  end
  def category
    h.link_to_competition(nil, model.competition, category: model.category)
  end
  def segment
    h.link_to_competition(nil, model.competition, category: model.category, segment: model.segment)
  end
end

################################################################
class SkatersController < ApplicationController
  ## index
  def filters
    {
      name: {operator: :like, input: :text_field},
      category: {operator: :eq, input: :select, model: Skater},
      nation: {operator: :eq, input: :select, model: Skater},
    }
  end
  def display_keys
    [ :name, :nation, :category, :isu_number]
  end
  def collection
    Skater.filter(filters, params).having_scores
  end
  def set_filter_keys
    decorator.set_filter_keys([:nation, :category])
  end

  def _index
    decorator = SkatersListDecorator

    render_index_as_formats(collection, filters: filters, display_keys: display_keys, decorator: decorator)
  end

  ## show
  def show
    show_skater(Skater.find_by(isu_number: params[:isu_number]))
  end
  def show_by_name
    show_skater(Skater.find_by(name: params[:name]))
  end
  def show_skater(skater)
    raise ActiveRecord::RecordNotFound.new("no such skater") if skater.nil?
    scores = SkaterScoresListDecorator.decorate_collection(skater.scores.recent.includes(:competition))

    respond_to do |format|
      format.html { render action: :show, locals: { skater: skater, scores: scores }}
      format.json { render json: skater}
    end
  end
end
