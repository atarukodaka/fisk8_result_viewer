################################################################
class CategorySummary
  include ApplicationHelper
  
  def initialize(competition)
    @competition = competition

    @categories = []
    @segments = Hash.new { |h,k| h[k] = [] }
    @top_rankers = Hash.new { |h,k| h[k] = [] }

    @competition.scores.order("date").pluck(:category, :segment).uniq.each do |cat_seg|
      category, segment = cat_seg
      @categories << category unless @categories.include?(category)
      @segments[category] << segment
    end
    @categories = sort_with_preset(@categories, ["MEN", "LADIES", "PAIRS", "ICE DANCE"])
    @competition.category_results.top_rankers(3).each do |item|
      @top_rankers[item.category] << item.skater_name
    end
  end
  def collection
    @categories.map do |category|
      {category: category, segments: @segments[category], top_rankers: @top_rankers[category]}
    end
  end
end
class CategorySummaryDecorator < EntryDecorator
  def category
    h.link_to_competition(model[:competition], category: model[:category])
  end
  def short
   h .link_to_competition(model[:competition], category: model[:category], segment: model[:segments].try(:first))
  end
  def free
   h .link_to_competition(model[:competition], category: model[:category], segment: model[:segments].try(:last))
  end
  def ranker1st
    model[:top_rankers].try(:[], 0)
  end
  def ranker2nd
    model[:top_rankers].try(:[], 1)
  end
  def ranker3rd
    model[:top_rankers].try(:[], 2)
  end
end
################################################################
class CompetitionsController < ApplicationController
  include ApplicationHelper
  
  def filters
    {
      name: ->(col, v) { col.where("name like ? ", "%#{v}%") },
      site_url: ->(col, v) { col.where("site_url like ?", "%#{v}%") },
      competition_type: ->(col, v) { col.where(competition_type: v) },
      isu_championships_only: ->(col, v) { col.where(isu_championships: v =~ /true/i)},
      season: ->(col, v) { col.where(season: v) },
    }
  end

  def display_keys
    [:cid, :name, :site_url, :city, :country, :competition_type, :season, :start_date, :end_date]
  end
  def collection
    filter(Competition.recent)
  end
  ################
  def category_summary_collection(competition)

    categories = []
    segments = Hash.new { |h,k| h[k] = [] }
    top_rankers = Hash.new { |h,k| h[k] = [] }

    competition.scores.order("date").pluck(:category, :segment).uniq.each do |cat_seg|
      category, segment = cat_seg
      categories << category unless categories.include?(category)
      segments[category] << segment
    end
    categories = helpers.sort_with_preset(categories, ["MEN", "LADIES", "PAIRS", "ICE DANCE"])
    competition.category_results.top_rankers(3).each do |item|
      top_rankers[item.category] << item.skater_name
    end
    categories.map do |category|
      {competition: competition, category: category, segments: segments[category], top_rankers: top_rankers[category]}
    end
  end
  def show
    competition = Competition.find_by(cid: params[:cid]) || raise(ActiveRecord::RecordNotFound)

    #category_summary = CategorySummary.new(competition)

    category = params[:category]
    segment = params[:segment]
   
    category_results = (category) ? CategoryResultDecorator.decorate_collection(competition.category_results.where(category: category).includes(:skater).includes(:scores)) : []
    segment_scores = (segment) ? SegmentScoreDecorator.decorate_collection(competition.scores.where(category: category).where("segment like ?", "#{segment}%").order(:ranking).includes(:skater)) : []

    respond_to do |format|
      format.html {
        render locals: {
          competition: competition.decorate,
          category: category, segment: segment,
          category_summary: CategorySummaryDecorator.decorate_collection(category_summary_collection(competition)),
          category_results: category_results,
          segment_scores: segment_scores,
        }
      }
      format.json {
        data = {
          competition_info: competition,
          #category_summary: CategorySummaryDecorator.decorate_collection(category_summary_collection(competition)),
        }
        data[:segment_scores] = segment_scores.object if segment
        data[:category_result] = category_results.object if category
        render json: data
      }
    end
  end
end
