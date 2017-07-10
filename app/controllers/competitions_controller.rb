class CompetitionsController < ApplicationController
  using SortWithPreset
  include Contracts
  def fetch_rows
    Competition.all
  end
  def order
    [[:start_date, :desc]]
  end
  def columns
    [
     :short_name, :name,
     :site_url, :city, :country, :competition_type,
     :season, :start_date, :end_date,
    ]
  end
  ################################################################
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    cat_seg = competition.scores.pluck(:category, :segment).uniq
    categories = cat_seg.map {|ary| ary[0]}.uniq
    cs_rows = categories.map do |category|
      segments = [:short, :free].map do |segment|
        [segment, cat_seg.select {|ary| ary[0] == category && ary[1] =~ /#{segment.upcase}/}.first.try(:last)]
      end.to_h
      CategorySummary.new(competition: competition, category: category, short: segments[:short], free: segments[:free])
    end
    category_summary = Datatable.new(cs_rows, [:category, :short, :free])

    result_type, result_datatable = 
      if category.blank? and segment.blank?
        [nil, nil]
      elsif segment.blank?
        [:category, Datatable.new(competition.category_results.category(category).includes(:skater, :scores),
                                  [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss])]
      else
        [:segment, Datatable.new(competition.scores.category(category).segment(segment).order(:ranking).includes(:skater, :elements, :components),
                                 [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,])]
      end
    
    respond_to do |format|
      locals = {
        competition: competition,
        category: category,
        segment: segment,
        category_summary: category_summary,
        result_type: result_type,
        result_datatable: result_datatable,
      }

      format.html {
        render :show, locals: locals
      }
      format.json {
        render json: competition.as_json.merge({results: result_datatable})
      }
    end
  end
end
