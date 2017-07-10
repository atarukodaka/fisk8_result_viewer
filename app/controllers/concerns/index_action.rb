module IndexAction
  ## shared
  def create_columns
    Columns.new(columns)
  end
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
  def list
    cols = create_columns
    rows = fetch_rows.where(filter_arel(cols))
    render json: ServersideDatatable.create(rows, columns, params: params)
  end
  def index
    cols = create_columns
    rows = fetch_rows.where(filter_arel(cols))
    table = Datatable.new(rows, cols)
    
    respond_to do |format|

      format.html {
        render :index, locals: {
          table: table
            .add_setting(:serverSide, true)
            .add_setting(:ajax, url_for(action: :list, format: :json, params: params.permit!))
            .add_setting(:order, order.map {|pair|
                           [cols.names.index(pair[0].to_s), pair[1]]
                         })
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

  ## for elements/components controllers
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
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
end
