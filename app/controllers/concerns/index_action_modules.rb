module IndexActionModules
  def list
    respond_to do |format|
      format.json {
        collection = create_collection()
        datatable = DataTable.new(params, collection, columns, filters)
        render json: datatable
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
  def index
    collection = create_collection()
    
    respond_to do |format|
      format.html {
        datatable = DataTable.new(params, collection, columns, filters)
        render locals: { datatable: datatable } 
      }
      format.json {
        render json: ListTable.new(params, collection, columns, filters)
      }
      format.csv {
        send_data ListTable.new(params, collection, columns, filters).to_csv, filename: "#{controller_name}.csv"
      }
    end
  end
end
