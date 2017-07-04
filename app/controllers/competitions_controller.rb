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
  def create_datatable
    super.add_option(:default_order, [:start_date, :desc])
=begin
    FilterDatatable.create(Competition.all, columns, filters: {}, params: params) do |table|
      fs = {
        name: ->(col, v) { col.name_matches(v) },
        site_url: ->(col, v) { col.site_url_matches(v) },
        competition_type: ->(col, v) { col.where(competition_type: v) },
        isu_championships_only: ->(col, v) { col.where(isu_championships: v.to_bool) },
        season: ->(col, v) { col.where(season: v) },
      }
      table.add_filters(fs)
      table.add_option(:default_order, [:start_date, :desc])
    end
=end
  end
  
  def columns
    [:short_name, :name, :site_url, :city, :country, :competition_type,
     :season, :start_date, :end_date]
  end

  ################################################################
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    category_segments = competition.scores.order(:date).select(:category, :segment).map {|d| d.attributes}.uniq.group_by {|d| d["category"]}.map {|k, ary|
      [k, ary.map {|d| d["segment"]}]
    }.to_h

    respond_to do |format|
      locals = {
        category: category,
        segment: segment,
        competition: competition,
        category_segments: category_segments,
        #category_summaries: Datatable.new(CategorySummary.create_summaries(competition), [:category, :short, :free, :ranker1st, :ranker2nd, :ranker3rd]),
        #category_summaries: Datatable.new(CategorySummary.all, [:category, :short]),
        category_results: (Datatable.new(competition.category_results.category(category).includes(:skater, :scores), [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss]) if category && segment.blank?),
        segment_scores: (Datatable.new(competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components), [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary]) if segment),
      }   # dont compact which can take category, segment out

      format.html {
        render :show, locals: locals
      }
      format.json {
        render :show, handlers: :jbuilder, locals: locals
      }
    end
  end
end
