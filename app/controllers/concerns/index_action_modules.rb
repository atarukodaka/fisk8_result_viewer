module IndexActionModules
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
    Datatable.new(collection, columns, filters: filters, params: params)
  end
  def index
    respond_to do |format|
      table = create_datatable
      format.html {
        render locals: { table: table.tap {|t| t.paging = true } }
      }
      format.json {
        render json: table.collection.limit(1000).map {|d| table.columns.keys.map {|k| [k, d.send(k)]}.to_h }.as_json
      }
      format.csv {
        csv = CSV.generate(headers: columns.keys, write_headers: true) do |csv|
          table.collection.limit(1000).each do |row|
            csv << table.columns.keys.map {|k| row.send(k)}
          end
        end
        send_data csv, filename: "#{controller_name}.csv"
      }
    end
  end
end
