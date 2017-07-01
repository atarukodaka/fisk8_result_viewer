module IndexActionModules
  ## for ajax request
  def list
    respond_to do |format|
      format.json {
        collection = create_collection()
        table = DataTable.new(collection, columns, params: params, filters: filters)
        collection = table.collection
        render json: {
          iTotalRecords: collection.model.count,
          iTotalDisplayRecords: collection.total_count,
          data: collection.decorate.map {|d| columns.keys.map {|k| [k, d.send(k)]}.to_h },
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
    DataTable.new(collection, columns)
  end
  def index
    #collection = create_collection()
    
    respond_to do |format|
      format.html {
        datatable = create_datatable
        render locals: { table: datatable } 
      }
      format.json {
        table = FilterTable.new(collection, columns, filters: filters, params: params)
        render json: table.collection.limit(1000).map {|d| columns.keys.map {|k| [k, d.send(k)]}.to_h }.as_json
      }
      format.csv {
        table = FilterTable.new(collection, columns, filters: filters, params: params)
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
