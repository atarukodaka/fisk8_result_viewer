class CompetitionsController < ApplicationController
  include ApplicationHelper
  include Contracts
  
  Contract None => Hash
  def filters
    {
      name: ->(col, v) { col.where("name like ? ", "%#{v}%") },
      site_url: ->(col, v) { col.where("site_url like ?", "%#{v}%") },
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
      format.html {
        render locals: {
          competition: competition.decorate,
          category: category,
          segment: segment,
          category_summary:  category_summary.map(&:decorate),
          category_results: category_results.map(&:decorate),
          segment_scores: segment_scores.map(&:decorate),
        }
      }
      format.json {
        locals = {
          competition: competition,
          category: category,
          segment: segment,
          category_summary: category_summary,
          segment_scores: segment_scores,
          category_results: category_results,
        }
        render :show, handlers: :jbuilder, locals: locals
      }
    end
  end
end
