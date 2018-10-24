require 'csv'

class IndexController < ApplicationController
  MAX_LENGTH = 1_000

  def limit_length
    #
    if params[:length]
      params[:length] = [params[:length].to_i, MAX_LENGTH].min
    else
      params[:length] = MAX_LENGTH
    end
  end

  def index
    datatable = create_datatable
    respond_to do |format|
      format.html {
        render :index, locals: {
          datatable: datatable.ajax(serverside: true, url: url_for(action: :list, format: :json)).defer_load
          #                 filters: "#{datatable.class}::Filters".constantize.new([], datatable: datatable),
        }
      }
      format.json {
        render json: datatable.serverside.limit(MAX_LENGTH).as_json
      }
      format.csv {
        csv = CSV.generate(headers: datatable.column_names, write_headers: true) do |c|
          datatable.serverside.limit(MAX_LENGTH).as_json.each { |row|  c << row }
        end
        send_data csv, filename: "#{controller_name}.csv"
      }
    end
  end

  ## json index access
  def list
    datatable = create_datatable.serverside.paging.decorate

    render json:  {
      iTotalRecords:        datatable.records.count,
             iTotalDisplayRecords: datatable.data.total_count,
             data:                 datatable.as_json,
    }
    # render json: create_datatable.serverside
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
