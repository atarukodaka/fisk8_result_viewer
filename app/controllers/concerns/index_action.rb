module IndexAction
  ## routed actions
  def list
    table = create_datatable.extend(Datatable::Serverside).tap {|t| t.params = params }
    render json: table
  end
  def index
    table = create_datatable

    respond_to do |format|
      format.html {
        render :index, locals: {
          table: table
            .add_setting(:serverSide, true)
            .add_setting(:ajax, url_for(action: :list, format: :json, params: params.permit!))
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
=begin
  def create_columns
    Columns.new(columns)
  end
=end
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
  def create_datatable
    klass = "#{controller_name.camelize}Datatable".constantize
    klass.new
  end
  
=begin
  def create_datatable(klass = nil)
    cols = create_columns
    rows = fetch_rows.where(filter_arel(cols))
    klass ||= Datatable
    klass.new(rows, cols)
  end
    
  
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
