class IndexController < ApplicationController
  def index
    datatable = create_datatable
    filters = begin
                "#{datatable.class}::Filters".constantize.new
              rescue NameError
                nil
              end
    respond_to do |format|
      format.html {
        render :index, locals: {
          datatable: datatable.ajax(serverside: true, url: url_for(action: :list, format: :json)).defer_load,
                 filters: filters,
        }
      }
      format.json {
        render json: datatable.limit.as_json
      }
      format.csv {
        require 'csv'
        csv = CSV.generate(headers: datatable.column_names, write_headers: true) do |c|
          datatable.limit.as_json.each do |row|
            c << row
          end
        end
        send_data csv, filename: "#{controller_name}.csv"
      }
    end
  end

  ## json index access
  def list
    render json: create_datatable.serverside
  end

  def data_to_show
    {}
  end

  def show
    respond_to do |format|
      format.html {     render locals: data_to_show }
      format.json {     render json: data_to_show }
    end
  end

  ################
  def create_datatable
    [controller_name.camelize, 'Datatable'].join.constantize.new(view_context)
  end
end
