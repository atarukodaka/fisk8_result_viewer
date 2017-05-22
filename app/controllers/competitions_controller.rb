class CompetitionsListDecorator < ListDecorator
  def name
    h.link_to_competition(model)
  end  
  def site_url
    h.link_to_competition_site("SITE", model)
  end
end
################
class CategoryResultsListDecorator < ListDecorator
  def skater_name
    h.link_to_skater(nil, model.skater)
  end
  def points
    _show_score(model.points)
  end
  def ranking
    _show_score(model.ranking, format: "%d")
  end
  def short_tss
    model.scores.first.tss
  end
  def free_ranking
    _show_score(model.free_ranking, format: "%d")
  end
  def free_tss
    #(f = model.scores.second) ? f.tss : "-"
    _show_score(model.scores.second.try(:tss))
  end
  
  protected
  def _show_score(value, format: "%3.2f")
    (value.to_f == 0) ? "-" : format % [ value ]    
  end

end


################
class SegmentScoresListDecorator < CategoryResultsListDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
  def tss
    _show_score(model.tss)
  end
  def tes
    _show_score(model.tes)
  end
  def pcs
    _show_score(model.pcs)
  end
  def deductions
    (model.deductions.to_f == 0) ? "" : model.deductions.to_f.abs * (-1)
  end


end
################################################################

class CategorySummary
  include ApplicationHelper
  
  def initialize(competition)
    @competition = competition

    @categories = []
    @segments = Hash.new { |h,k| h[k] = [] }
    @top_rankers = Hash.new { |h,k| h[k] = [] }

    @competition.scores.order("date").pluck(:category, :segment).uniq.each do |ary|
      category, segment = ary   # = ary.first; segment = ary.second
      @categories << category unless @categories.include?(category)
      @segments[category] << segment
    end
    @categories = sort_with_preset(@categories, ["MEN", "LADIES", "PAIRS", "ICE DANCE"])
    @competition.category_results.where("ranking > 0 and ranking <= ? ", 3).order(:ranking).each do |item|
      @top_rankers[item.category] << item.skater_name
    end
  end
  def collection
    @categories.map do |category|
      {category: category, segments: @segments[category], top_rankers: @top_rankers[category]}
    end
  end
end

################################################################
class CompetitionsController < ApplicationController
  def filters
    {
      name: {operator: :like, input: :text_field, model: Competition},
      site_url: {operator: :like, input: :text_field, model: Competition},
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
    ## category summary
    category = params[:category]
    segment = params[:segment]

    category_summary = CategorySummary.new(competition)
    
    category_results = (category) ? CategoryResultsListDecorator.decorate_collection(competition.category_results.where(category: category).includes(:skater).includes(:scores)) : []
    segment_scores = (segment) ? SegmentScoresListDecorator.decorate_collection(competition.scores.where(category: category, segment: segment).order(:ranking).includes(:skater)) : []

    respond_to do |format|
      format.html {
        render locals: {
          competition: competition, category: category, segment: segment,
          category_summary: category_summary,
          category_results: category_results,
          segment_scores: segment_scores,
        }
      }
      format.json {
        data = {competition_info: competition, category_summary: category_summary}
        data[:segment_scores] = segment_scores if segment
        data[:category_result] = category_results if category
        render json: data
      }
    end
  end
end
