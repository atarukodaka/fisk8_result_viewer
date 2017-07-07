class IndexDatatable < Datatable
  ## for elements/components
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
  end
  def manipulate_collection(col)
    execute_filters(super(col))
  end
  def execute_filters(col)
    columns.each do |column|
      if (sv = params[column[:name]].presence)
        col =
          if (filter = column[:filter] )
            filter.call(col, sv)
          else
            col.where("#{column[:key]} like ? ", "%#{sv}%")
          end
      end
    end
    col
  end

end
