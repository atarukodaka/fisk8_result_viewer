class CompetitionsController < ApplicationController
  include ApplicationHelper
  include Contracts
  
  Contract None => Hash
  def filters
    {
      name: ->(col, v) { col.name_matches(v) },
      site_url: ->(col, v) { col.site_url_matches(v) },
      competition_type: ->(col, v) { col.where(competition_type: v) },
      isu_championships_only: ->(col, v) { col.where(isu_championships: v.to_bool) },
      season: ->(col, v) { col.where(season: v) },
    }
  end
  Contract None => ActiveRecord::Relation
  def create_collection
    #Competition.recent
    Competition.all
  end
  def default_sort_key
    { key: :start_date, direction: :desc }
  end
  ################################################################
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    collections = {
      competition: competition,
      category_summaries: CategorySummary.create_summaries(competition),
      category_results: (competition.category_results.category(category).includes(:skater, :scores) if category && segment.blank?) || [],
      segment_scores: (competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components) if segment) || [],
    }

    respond_to do |format|
      locals = {
          category: category,
          segment: segment,
      }
      format.html {
        render :show, locals: collections.reject {|_, v| v.blank?}.map {|k, v| [k, v.decorate]}.to_h.merge(locals)
      }
      format.json {
        render :show, handlers: :jbuilder, locals: collections.merge(locals)
      }
    end
  end
end
