class CompetitionsController < ApplicationController
  using SortWithPreset
  include Contracts

  def list
    Datatable
    cols = Columns.new(columns)
    rows = Competition.all.where(filter_arel(cols))
    table = ServersideDatatable.new(columns: columns, rows: rows, params: params)
    render json: table
=begin
    render json: {
      "data": [
               {
                 "name": "SCORE",
                 "category": "CATEGORY"	    
               }
              ]
    }
=end
  end
  ################################################################

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
  def filter_arel(cols)
    keys = []
    values = []
    cols.map do |column|
      sv = params[column[:name]] || next
      keys << "#{column.key} like ? "
      values << "%#{sv}%"
    end
    [keys.join(' and '), *values]
  end
  def index
    respond_to do |format|
      Datatable
      
      #table = Datatable.new(columns: [:name, :competition_name, :skater_name], collection: Score.includes(:competition, :skater).limit(10))

      #table = Datatable.new(columns: [:name, :competition_name, :skater_name], collection: [{name: "foo", competition_name: "compe", skater_name: "bar"}])
      
      #table = Datatable.new(columns: [:name], settings: {ajax: "list.txt"})
      format.html {
        cols = Columns.new(columns)
        table = Datatable.new(columns: cols, settings: {ajax: url_for(action: :list, format: :json, params: params.permit(cols.names)), serverSide: true})
        if order.present?
          table.settings[:order] = order.map {|pair|
            [table.column_names.index(pair[0].to_s), pair[1]]
          }
        end
        render :index, locals: {table: table }
      }
      format.json {
        cols = Columns.new(columns)
        rows = Competition.limit(100).where(filter_arel)
        table = Datatable.new(columns: cols, rows: rows)
        # filter
        
        render json: table
      }
      
    end
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
        [:category, CategoryResultsDatatable.new(results: competition.category_results.category(category))]
      else
        [:segment, SegmentScoresDatatable.new(scores: competition.scores.category(category).segment(segment))]
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
