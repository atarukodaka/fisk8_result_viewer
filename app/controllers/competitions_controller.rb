class CompetitionsListDecorator < ListDecorator
  def name
    h.link_to_competition(model)
  end  
  def site_url
    h.link_to_competition_site("SITE", model)
  end
end
class SegmentScoresListDecorator < ListDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
end
################################################################

class CategorySummary
  include ApplicationHelper
  
  def initialize(competition)

    @competition = competition

    @_categories = []
    @_segments = Hash.new { |h,k| h[k] = [] }
    @_top_rankers = Hash.new { |h,k| h[k] = [] }

    @competition.scores.order("date").pluck(:category, :segment).uniq.each do |ary|
      category, segment = ary   # = ary.first; segment = ary.second
      @_categories << category unless @_categories.include?(category)
      @_segments[category] << segment
    end
    @_categories = sort_with_preset(@_categories, ["MEN", "LADIES", "PAIRS", "ICE DANCE"])
    @competition.category_results.where("ranking > 0 and ranking <= ? ", 3).order(:ranking).each do |item|
      @_top_rankers[item.category] << item.skater_name
    end
  end
  def collection
    @_categories.map do |category|
      {category: category, segments: @_segments[category], top_rankers: @_top_rankers[category]}
    end
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
    decorator.set_filter_keys([:competition_type, :season])
  end
  def collection
    Competition.recent.filter(filters, params)
  end
  ################
  def show
    competition = Competition.find_by(cid: params[:cid]) || raise(ActiveRecord::RecordNotFound)
    data = competition.scores.pluck(:category, :segment, :ranking, :skater_name).uniq.sort
    cat_seg = data.map {|d| d[0..1]}.uniq
    aa = []
    cat_seg.map do |c_s|
      aa << data.select {|d| d[0] == c_s[0] && d[1] == c_s[1]}
    end
    ## category summary
    category = params[:category]
    segment = params[:segment]
    segment_scores = (segment) ? SegmentScoresListDecorator.decorate_collection(competition.scores.where(category: category, segment: segment).order(:ranking)) : []
    render locals: {competition: competition, category: category, segment: segment, segment_scores: segment_scores, category_summary: CategorySummary.new(competition)}
    
=begin
    respond_to do |format|
      format.html { }
      format.json { render json: @competition }
    end
=end
  end
end
