module IndexAction
  ## for ajax request
  def list
    respond_to do |format|
      format.json {

        #collection = create_collection.page(0).per(10)
        #table = create_datatable
        table = ServersideDatatable.new(execute_filters(create_collection), columns, filters: filters, params: params)
        collection = table.collection
        
        render json: {
          iTotalRecords: collection.model.count,
          iTotalDisplayRecords: collection.total_count,
          data: collection.decorate.map {|item|
            table.column_names.map {|c| [c, item.send(c)]}.to_h
            #{name: item.name, short_name: item.short_name}
          }
          
=begin
          columns: collection.decorate.map {|d|
            table.column_names.map {|k| [k, d.send(k.to_sym)]}.to_h
          },
=end
        }
      }
    end
  end
  ################################################################

  def filters
    {}
  end
  def execute_filters(col)
    # input params
    filters.each do |key, pr|
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
  def columns
    {}
  end
  def create_collection
    raise "should be implemented in derived class"
  end
=begin
  def collection
    @collection ||= create_collection
  end
=end
  def create_datatable
    #Datatable.create(create_collection, columns, filters: filters, params: params)
    Datatable.create(execute_filters(create_collection), columns)
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
