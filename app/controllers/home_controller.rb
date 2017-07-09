class HomeController < ApplicationController
  def order
    #[[:category, :asc]]
    nil
  end
  def columns
    [:name, :category]
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
        rows = Skaters.limit(100).where(filter_arel)
        table = Datatable.new(columns: cols, rows: rows)
        # filter
        
        render json: table
      }
      
    end
  end
  def list
    Datatable
    cols = Columns.new(columns)
    rows = Skater.all.where(filter_sql(cols))
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
end
