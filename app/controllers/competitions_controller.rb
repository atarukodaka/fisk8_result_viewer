class CompetitionsController < ApplicationController
  using SortWithPreset
  include Contracts
  def fetch_rows
    Competition.all
  end
  def order
    #[[:start_date, :desc]]
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

    category_segments = competition.scores.order(:date).select(:category, :segment).map {|d| d.attributes}.uniq.group_by {|d| d["category"]}.map {|k, ary|
      [k, ary.map {|d| d["segment"]}]
    }.to_h
    categories = category_segments.keys.sort_with_preset(["MEN", "LADIES", "PAIRS", "ICE DANCE"])
      
    result_type, result_datatable = 
      if category.blank? and segment.blank?
        [nil, nil]
      elsif segment.blank?
        [:category, Datatable.new(competition.category_results.category(category).includes(:skater, :scores).decorate,
                                  [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss])]
      else
        [:segment, Datatable.new(competition.scores.category(category).segment(segment).order(:ranking).includes(:skater, :elements, :components).decorate,
                                 [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,])]
      end
    
    respond_to do |format|
      locals = {
        competition: competition,
        category: category,
        segment: segment,
        categories: categories,
        category_segments: category_segments,
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
