module IndexAction
  ## routed actions
  def list
=begin    
    table = create_datatable do |t|
      t.extend Datatable::Serverside
      t.params = params
    end
=end
    table = create_datatable.extend(Datatable::Serverside).set_params(params)
    render json: table
  end
  def index
    table = create_datatable

    respond_to do |format|
      format.html {
        additional_settings = {
          serverSide: true,
          ajax: {
            url: url_for(action: :list, format: :json, params: params.permit!),
          },
        }
        render :index, locals: {
          table: table.add_settings(additional_settings)
        }
      }
      format.json {
        render json: table
      }
      format.csv {
        send_data table.to_csv, filename: "#{controller_name}.csv"
      }
    end
  end

  ################
  # unrouted methods
  def create_datatable
    klass = "#{controller_name.camelize}Datatable".constantize
    klass.new do |obj|
      yield obj if block_given?
    end
  end
=begin
  def filter_arel(cols)
    arel = nil
    cols.map do |column|
      sv = params[column.name].presence || next
      this_arel =
        if (filter_proc = column.filter)
          filter_proc.call(sv)
        else
          model = (column.table.presence || controller_name).classify.constantize
          this_arel = model.arel_table[column.column_name].matches("%#{sv}%")
        end
      arel = (arel) ? arel.and(this_arel) : this_arel
    end
    arel    
  end
=end
  
=begin
  
  ## to be overriden
  def fetch_rows
    raise "override in derived class"
  end
  def order
    []
  end
  def columns
    []
  end
=end
  ################################################################
end
