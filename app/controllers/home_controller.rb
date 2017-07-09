class HomeController < ApplicationController
  def order
    #[[:category, :asc]]
    nil
  end
  def columns
    [:name, :category]
  end

  def index
    respond_to do |format|
      Datatable
      
      #table = Datatable.new(columns: [:name, :competition_name, :skater_name], collection: Score.includes(:competition, :skater).limit(10))

      #table = Datatable.new(columns: [:name, :competition_name, :skater_name], collection: [{name: "foo", competition_name: "compe", skater_name: "bar"}])
      
      #table = Datatable.new(columns: [:name], settings: {ajax: "list.txt"})
      table = Datatable.new(columns: columns, settings: {ajax: url_for(action: :list, format: :json), serverSide: true})
      if order.present?
        table.settings[:order] = order.map {|pair|
          [table.column_names.index(pair[0].to_s), pair[1]]
        }
      end
      format.html {
        render :index, locals: {table: table }
      }
      format.json {
        table.rows = Skater.limit(100)
        render json: table
      }
      
    end
  end
  def list
    Datatable
    table = ServersideDatatable.new(columns: columns, rows: Skater.all, params: params)
                          
    #table = ServersideDatatable.new(columns: [{name: "name", table: "skaters", column_name: "name"}], collection: Skater.all, params: params)
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
