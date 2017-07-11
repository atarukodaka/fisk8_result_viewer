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
  def competition_info(competition)
    Listtable.new(competition, [:name, :short_name, :competition_type, :city, :country, :site_url, :start_date, :end_date, :comment])
  end
    
  def category_segments(competition)
    cat_seg = competition.scores.pluck(:category, :segment).uniq
    categories = cat_seg.map {|ary| ary[0]}.uniq  # TODO: sort_with_preset ??
    cs_rows = categories.map do |category|
      segments = [:short, :free].map do |segment|
        [segment, cat_seg.select {|ary| ary[0] == category && ary[1] =~ /#{segment.upcase}/}.first.try(:last)]
      end.to_h
      CategorySummary.new(competition: competition, category: category, short: segments[:short], free: segments[:free])
    end
    Datatable.new(cs_rows, [:category, :short, :free])    
  end
  def result_type(category, segment)
    if category.blank? && segment.blank?
      :none
    elsif segment.blank?
      :category
    else
      :segment
    end
  end
  def result_datatable(competition, category, segment)
    case result_type(category, segment)
    when :category
      Datatable.new(competition.category_results.category(category).includes(:skater, :scores),
                    [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss])
    when :segment
      Datatable.new(competition.scores.category(category).segment(segment).order(:ranking).includes(:skater, :elements, :components),
                    [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,])
    else
      nil
    end
  end    
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    respond_to do |format|
      locals = {
        competition: competition,
        category: category,
        segment: segment,
        competition_info: competition_info(competition),
        category_summary: category_segments(competition),
        result_type: result_type(category, segment),
        result_datatable: result_datatable(competition, category, segment),
      }

      format.html {
        render :show, locals: locals
      }
      format.json {
        render json: competition.as_json.merge({results: result_datatable(competition, category, segment)})
      }
    end
  end
end
