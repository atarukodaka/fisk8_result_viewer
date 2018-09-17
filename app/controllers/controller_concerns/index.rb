module ControllerConcerns::Index
  def index
    table = create_datatable
    respond_to do |format|
      format.html {
        render :index, locals: {
          table: table.ajax(serverside: true, url: url_for(action: :list, format: :json)).defer_load
        }
      }
      format.json {
        render json: table.limit.as_json
      }
      format.csv {
        require 'csv'
        csv = CSV.generate(headers: table.column_names, write_headers: true) do |c|
          table.limit.as_json.each do |row|
            c << row
          end
        end
        
        send_data csv, filename: "#{controller_name}.csv" }
    end
  end
  ## json index access
  def list
    render json: create_datatable.serverside
  end
  ################

  def create_datatable
    [controller_name.camelize, "Datatable"].join.constantize.new(view_context)
  end
end