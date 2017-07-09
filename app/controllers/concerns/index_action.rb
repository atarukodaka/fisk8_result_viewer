module IndexAction
  ## shared
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
    render json: ServersideDatatable.create(nil, columns, params: params){|table|
      table.rows = fetch_rows.where(filter_arel(table.columns))
    }

  end
  def index
    respond_to do |format|
      format.html {
        render :index, locals: {
          table: Datatable.create(nil, columns, settings: {serverSide: true}){|table|
            #table.settings[:ajax] = url_for(action: :list, format: :json, params: params.permit(table.columns.names))
            table.settings[:ajax] = url_for(action: :list, format: :json, params: params.permit!)
            if order.present?
              table.settings[:order] = order.map {|pair|
                [table.column_names.index(pair[0].to_s), pair[1]]
              }
            end
          }
        }

      }
      format.json {
        render json: Datatable.create(nil, columns) {|table|
          table.rows = fetch_rows.where(filter_arel(table.columns)).limit(1000)
        }
      }
      format.csv {
        require 'csv'
        table = Datatable.create(nil, columns){|table|
          table.rows = fetch_rows.where(filter_arel(table.columns)).limit(1000)
        }
        csv = CSV.generate(headers: table.column_names, write_headers: true) do |csv|
          table.rows.each do |row|
            csv << table.column_names.map {|k| row.send(k)}
          end
        end
        send_data csv, filename: "#{controller_name}.csv"
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
