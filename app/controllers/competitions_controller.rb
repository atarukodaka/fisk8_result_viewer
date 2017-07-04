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
    competition = Competition.where(short_name: params[:short_name]).last || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    respond_to do |format|

      locals = {
        category: category,
        segment: segment,
        competition: competition,
        category_summaries: Datatable.new(CategorySummary.create_summaries(competition), [:category, :short, :free, :ranker1st, :ranker2nd, :ranker3rd]),
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
  ################################################################
  def create_competition
  end
  def show_competition
    url = params[:url]
    parser_type = params[:parser_type].presence || :isu_generic
    parser = Parsers.get_parser(parser_type.to_sym)
    
    summary = Adaptor::CompetitionAdaptor.new(parser.parse(:competition, url))
    render locals: { summary: summary, parser: parser }
  end
end
