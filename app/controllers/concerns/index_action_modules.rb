module IndexActionModules
  ## for ajax request
  def list
    respond_to do |format|
      format.json {
        table = Datatable.new(collection, columns, params: params, filters: filters, paging: true)
        render json: {
          iTotalRecords: table.collection.model.count,
          iTotalDisplayRecords: table.collection.total_count,
          data: table.collection.decorate.map {|d| columns.keys.map {|k| [k, d.send(k)]}.to_h },
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
    Datatable.new(collection, columns)
  end
  def index
    respond_to do |format|
      table = create_datatable
      format.html {
        render locals: { table: table.paging(true) }
      }
      format.json {
        render json: table.collection.limit(1000).map {|d| columns.keys.map {|k| [k, d.send(k)]}.to_h }.as_json
      }
      format.csv {
        csv = CSV.generate(headers: columns.keys, write_headers: true) do |csv|
          table.collection.limit(1000).each do |row|
            csv << columns.keys.map {|k| row.send(k)}
          end
        end
        send_data csv, filename: "#{controller_name}.csv"
      }
    end
  end
end
