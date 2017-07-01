################################################################
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
    Competition.all
  end
  def columns
    {
      short_name: "short_name", name: "name", site_url: "site_url", city: "city",
      country: "country", competition_type: "competition_type", season: "season",
      start_date: "start_date", end_date: "end_date",
    }
  end
  ################################################################
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    respond_to do |format|

      locals = {
        category: category,
        segment: segment,
        competition: competition,
        category_summaries: ListTable.new(CategorySummary.create_summaries(competition), [:category, :short, :free, :ranker1st, :ranker2nd, :ranker3rd]),
        category_results: (ListTable.new(competition.category_results.category(category).includes(:skater, :scores), [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss]) if category && segment.blank?),
        segment_scores: (ListTable.new(competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components), [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary]) if segment),
      }
=begin
      locals_to_decorate = {
        competition: competition,
        category_summaries: CategorySummary.create_summaries(competition),
        category_results: (competition.category_results.category(category).includes(:skater, :scores) if category && segment.blank?),
        segment_scores: (competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components) if segment),
      }.compact
=end      
      format.html {
        #render :show, locals: locals.merge(locals_to_decorate.transform_values {|v| v.decorate})
        render :show, locals: locals  # .merge(locals_to_decorate) 
      }
      format.json {
        render :show, handlers: :jbuilder, locals: locals
      }
    end
  end
end
