class CompetitionsController < ApplicationController
  include ApplicationHelper
  include Contracts
  
  Contract None => Hash
  def filters
    {
      name: ->(col, v) { col.matches(:name, v) },
      site_url: ->(col, v) { col.matches(:site_url, v) },
      competition_type: ->(col, v) { col.where(competition_type: v) },
      isu_championships_only: ->(col, v) { col.where(isu_championships: v =~ /true/i)},
      season: ->(col, v) { col.where(season: v) },
    }
  end

  Contract None => ActiveRecord::Relation
  def collection
    filter(Competition.recent)
  end
  ################################################################
  def show
    competition = Competition.find_by(cid: params[:cid]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]
   
    category_summary = CategorySummary.new(competition)
    category_results = (competition.category_results.category(category).includes(:skater, :scores) if category && segment.blank?) || []
    segment_scores = (competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components) if segment) || []

    respond_to do |format|
      locals = {
          category: category,
          segment: segment,
      }
      format.html {
        locals[:competition] = competition.decorate
        locals[:category_summary] = CategorySummaryDecorator.decorate_collection(category_summary)
        locals[:category_results] = CategoryResultDecorator.decorate_collection(category_results.all) unless category_results.blank?
        locals[:segment_scores] =  SegmentScoreDecorator.decorate_collection(segment_scores.all) unless segment_scores.blank?
        render :show, locals: locals
      }
      format.json {
        render :show, handlers: :jbuilder, locals: {
          competition: competition,
          category_summary: category_summary,
          segment_scores: segment_scores,
          category_results: category_results,
        }.merge(locals)
      }
    end
  end
end
