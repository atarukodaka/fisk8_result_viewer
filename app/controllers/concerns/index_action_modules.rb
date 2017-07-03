module IndexActionModules
  ## for ajax request
  def list
    respond_to do |format|
      format.json {
        table = create_datatable.extend(ServersideDatatableModule)
        render json: {
          iTotalRecords: table.collection.model.count,
          iTotalDisplayRecords: table.collection.total_count,
          data: table.collection.decorate.map {|d|
            table.column_names.map {|k| [k, d.send(k)]}.to_h
          },
        }
      }
    end
  end
  ################################################################
  def filters
    {}
  end
  def columns
    {}
  end
  def create_collection
    raise "should be implemented in derived class"
  end
  def collection
    @collection ||= create_collection
  end

  def create_datatable
    FilterDatatable.create(collection, columns, filters: filters, params: params)
  end
  def index
    respond_to do |format|
      table = @table || create_datatable
      format.html {
        render locals: { table: table }
      }
      format.json {
        render json: table.collection.limit(1000).map do |d|
          table.column_names.map {|k| [k, d.send(k)]}.to_h
        end
      }
      format.csv {
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
