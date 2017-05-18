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
  def index
    filters = {
      name: {operator: :like, input: :text_field, model: Competition},
      competition_type: {operator: :eq, input: :select, model: Competition},
      season: {operator: :eq, input: :select, model: Competition},
    }
    display_keys = [:cid, :name, :site_url, :city, :country, :competition_type, :season, :start_date, :end_date]
    CompetitionsListDecorator.set_filter_keys([:competition_type, :season])
    collection = Competition.recent.filter(filters, params)
    render_index_as_formats(collection, filters: filters, display_keys: display_keys, decorator: CompetitionsListDecorator)
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
