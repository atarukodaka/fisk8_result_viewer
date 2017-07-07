class CompetitionsController < ApplicationController
  using SortWithPreset
  include Contracts

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
        [:category, CategoryResultsDatatable.new(results: competition.category_results.category(category))]
      else
        [:segment, SegmentScoresDatatable.new(scores: competition.scores)]
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
