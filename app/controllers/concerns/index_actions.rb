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
        serverside_settings = {
          serverSide: true,
          ajax: {
            url: url_for(action: :list, format: :json, params: params.permit!),
          },
        }
        render :index, locals: {
          table: table.update_settings(serverside_settings)
        }
      }
      format.json { render json:
        table.data.limit(max_limit).map do |item|
          column_names.map do |column|
            [column, item.send(column)]
          end.to_h
        end
      }
      format.csv {
        require 'csv'
        csv = CSV.generate(headers: table.column_names, write_headers: true) do |csv|
          table.data.limit(max_limit).each do |row|
            csv << table.column_names.map {|k| row.send(k)}
          end
        end
        send_data csv, filename: "#{controller_name}.csv" }
    end
  end

  ################
  # unrouted methods
  def create_datatable(serverside: false)
    [controller_name.camelize, Datatable].join.constantize.new(view_context)
  end
end
