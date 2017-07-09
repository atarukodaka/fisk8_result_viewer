module IndexAction
  ## for ajax request
  def list
    respond_to do |format|
      format.json {
        render json: create_datatable.extend(Datatable::Serverside)
      }
    end
  end
  def create_datatable
    begin
      klass = "#{controller_name.camelize}IndexDatatable".constantize
    rescue NameError
      raise "#{controller_name}IndexDatatable not found"
    else
      klass.create(params: params)
    end
  end
  def index
    respond_to do |format|
      #table = create_datatable
      table = Datatable.new(columns: columns, settings: {ajax: url_for(action: :list, format: :json), serverSide: true})
      params_to_pass = {}
      table.column_names.map {|column_name|
        params_to_pass[column_name] = params[column_name] if params[column_name].present?
      }

      format.html {
        table.ajax = url_for(action: :list, format: :json, params: params_to_pass)
        render locals: { table: table }
      }
      format.json {
        render json: table.collection.limit(1000).map do |d|
          table.column_names.map {|k| [k, d.send(k)]}.to_h
        end
      }
      format.csv {
        require 'csv'
        csv = CSV.generate(headers: table.column_names, write_headers: true) do |csv|
          table.collection.limit(1000).each do |row|
            csv << table.column_names.map {|k| row.send(k)}
          end
        end
        send_data csv, filename: "#{controller_name}.csv"
      }
    end
  end
end
