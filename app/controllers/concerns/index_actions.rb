module IndexActions
  ## routed actions
  def list
    render json: create_datatable
  end
  def index
    table = create_datatable
    max_limit = 10_000

    respond_to do |format|
      format.html {
        render :index, locals: {
          table: table.ajax(serverside: true, url: url_for(action: :list, format: :json, params: params.permit!))
        }
      }
      format.json {
        render json: table.data.limit(max_limit).map do |item|
          table.column_names.map do |column|
            #[column, item.send(column)]
            [column, table.value(item, column)]
          end.to_h
        end
      }
      format.csv {
        require 'csv'
        csv = CSV.generate(headers: table.column_names, write_headers: true) do |csv|
          table.data.limit(max_limit).each do |row|
            csv << table.column_names.map {|k| table.value(row, k)}
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
