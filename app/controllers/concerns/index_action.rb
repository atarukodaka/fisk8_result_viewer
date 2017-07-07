module IndexAction
  ## for ajax request
  def list
    respond_to do |format|
      format.json {
        render json: Datatable.new(create_collection, columns, params: params).extend(Datatable::Serverside)
      }
    end
  end
  def columns
    {}
  end
  def create_collection
    raise "should be implemented in derived class"
  end
  def create_datatable
    klass = "#{controller_name.singularize}Datatable".constantize
    binding.pry
    klass.create(create_collection, columns)
    
    #Datatable.create(create_collection, columns)

  end
  def index
    respond_to do |format|
      table = create_datatable
      format.html {
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
