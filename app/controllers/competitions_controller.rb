class CompetitionsListDecorator < Draper::Decorator
  include ListDecorator

  def name
    h.link_to_competition(model)
  end  
  def site_url
    h.link_to_competition_site("SITE", model)
  end
end
class SegmentScoresListDecorator < Draper::Decorator
  include ListDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
end

################################################################
class CompetitionsController < ApplicationController
  def filters
    {
      name: {operator: :like, input: :text_field, model: Competition},
      competition_type: {operator: :eq, input: :select, model: Competition},
      season: {operator: :eq, input: :select, model: Competition},
    }
  end
  
  def display_keys
    [:cid, :name, :site_url, :city, :country, :competition_type, :season, :start_date, :end_date]
  end
  def set_filter_keys
    CompetitionsListDecorator.set_filter_keys([:competition_type, :season])
  end
  def collection
    Competition.recent.filter(filters, params)
  end

  def show
    @competition = Competition.find_by(cid: params[:cid]) || raise(ActiveRecord::RecordNotFound)
    @category = params[:category]
    @segment = params[:segment]
    @segment_scores = SegmentScoresListDecorator.decorate_collection(@competition.scores.where(category: @category, segment: @segment).order(:ranking))
    
=begin
    respond_to do |format|
      format.html { }
      format.json { render json: @competition }
    end
=end
  end
end
