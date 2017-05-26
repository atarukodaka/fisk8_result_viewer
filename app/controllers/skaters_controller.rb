################
class SkatersListDecorator < ListDecorator
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

class SkaterCompetitionsListDecorator < ListDecorator
  include ApplicationHelper

  def competition_name
    h.link_to_competition(nil, model.competition)
  end
  def date
    model.competition.start_date
  end
  def ranking
    h.link_to_competition(as_ranking(model.ranking), model.competition, category: model.category)
  end
  def points
    h.link_to_competition(as_score(model.points), model.competition, category: model.category)
    
  end
  def short_ranking
    h.link_to_score(as_ranking(model.short_ranking), model.scores.first)
  end
  def free_ranking
    h.link_to_score(as_ranking(model.free_ranking), model.scores.first)
  end
  def short_tss
    h.link_to_score(as_score(model.scores.first.try(:tss)), model.scores.first)
  end
  def free_tss
    h.link_to_score(as_score(model.scores.second.try(:tss)), model.scores.second)
  end
end
################################################################
class SkatersController < ApplicationController
  ## index
  def filters
    @_filters ||= IndexFilters.new.tap do |f|
      f.filters = {
        name: {operator: :like, input: :text_field, model: Skater},
        category: {operator: :eq, input: :select, model: Skater},
        nation: {operator: :eq, input: :select, model: Skater},
      }
    end
  end
  def display_keys
    [ :name, :nation, :category, :isu_number]
  end
  def collection
    Skater.filter(filters.create_arel_tables(params)).having_scores
  end
  ################
  ## show
  def show
    show_skater(Skater.find_by(isu_number: params[:isu_number]))
  end
  def show_by_name
    show_skater(Skater.find_by(name: params[:name]))
  end
  def show_skater(skater)
    raise ActiveRecord::RecordNotFound.new("no such skater") if skater.nil?

    collection = skater.category_results.with_competition.recent.includes(:competition)
    category_results = SkaterCompetitionsListDecorator.decorate_collection(collection)
    
    #collection = skater.category_results.includes(:competition)
    #category_results = SkaterCompetitionsListDecorator.decorate_collection(collection.includes(:scores).order("scores.date desc"))

    respond_to do |format|
      format.html { render action: :show, locals: { skater: skater, category_results: category_results }}
      format.json { render json: {skater_info: skater, competition_results: skater.category_results} }
    end
  end
end
