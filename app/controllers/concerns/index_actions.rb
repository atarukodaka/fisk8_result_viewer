module IndexActions
  ## routed actions
  def list
    render json: create_datatable.serverside
  end
  def index
    table = create_datatable
    max_limit = 10_000

    respond_to do |format|
      format.html {
        render :index, locals: {
          table: table.ajax(serverside: true, url: url_for(action: :list, format: :json, params: params.permit!))  # .defer_load
        }
      }
      format.json {
        #render json: table.expand_data(table.data.limit(max_limit))
        render json: table.as_json
      }
      format.csv {
        require 'csv'
        csv = CSV.generate(headers: table.column_names, write_headers: true) do |csv|
          table.as_json.each do |row|
            csv << row
          end
        end
        
        send_data csv, filename: "#{controller_name}.csv" }
    end
  end

  ################
  # unrouted methods
  def create_datatable
    [controller_name.camelize, Datatable].join.constantize.new(view_context)
  end
end
