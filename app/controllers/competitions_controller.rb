class CompetitionDecorator < EntryDecorator
  class << self
    def headers
      { competition_type: "Type" }
    end
  end
  def name
    n = h.link_to_competition(model)
    (model.isu_championships) ? h.content_tag(:b, n) : n
  end  
  def site_url
    h.link_to_competition_site("Official", model)
  end
end
################
class CategoryResultDecorator < EntryDecorator
  def skater_name
    h.link_to_skater(nil, model.skater)
  end
  def short_tss
    as_score(model.scores.first.try(:tss))
  end
  def free_tss
    as_score(model.scores.second.try(:tss))
  end
  self.display_as(:ranking, [:short_ranking, :free_ranking])
  self.display_as(:score, [:points])
end

################
class SegmentScoreDecorator < CategoryResultDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
  self.display_as(:score, [:tss, :tes, :pcs, :deductions])
end
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

################################################################
class CompetitionsController < ApplicationController
  def filters
    @_filters ||= IndexFilters.new.tap do |f|
      f.filters = {
        name: {operator: :like, input: :text_field, model: Competition},
        site_url: {operator: :like, input: :text_field, model: Competition},
        type: {
          children: {
            competition_type: {operator: :eq, input: :select, model: Competition, label: ""},
            isu_championships: { operator: :eq, input: :checkbox, model: Competition, value: true, label: "ISU Championships Only"},
          },
        },
        season: {operator: :eq, input: :select, model: Competition},
      }
    end
  end
  
  def display_keys
    [:cid, :name, :site_url, :city, :country, :competition_type, :season, :start_date, :end_date]
  end
  def collection
    Competition.recent.filter(filters.create_arel_tables(params))
  end
  ################
  def show
    competition = Competition.find_by(cid: params[:cid]) || raise(ActiveRecord::RecordNotFound)
    ## category summary
    category = params[:category]
    segment = params[:segment]

    category_summary = CategorySummary.new(competition)
    
    category_results = (category) ? CategoryResultDecorator.decorate_collection(competition.category_results.where(category: category).includes(:skater).includes(:scores)) : []
    segment_scores = (segment) ? SegmentScoreDecorator.decorate_collection(competition.scores.where(category: category).where("segment like ?", "#{segment}%").order(:ranking).includes(:skater)) : []

    respond_to do |format|
      format.html {
        render locals: {
          competition: competition.decorate,
          category: category, segment: segment,
          category_summary: category_summary,
          category_results: category_results,
          segment_scores: segment_scores,
        }
      }
      format.json {
        data = {competition_info: competition, category_summary: category_summary}
        data[:segment_scores] = segment_scores.object if segment
        data[:category_result] = category_results.object if category
        render json: data
      }
    end
  end
end
