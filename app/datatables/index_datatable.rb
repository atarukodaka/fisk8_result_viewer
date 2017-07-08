class IndexDatatable < Datatable
  def model
    self.class.to_s =~ /^(.*)IndexDatatable/
    $1.singularize.constantize
  end
  def columns=(col)
    super(col)
    columns.each {|col| col[:model] ||= model; col[:column_name] ||= col[:name] }
  end
  def manipulate_collection(col)
    #execute_filters(super(col))
    super(col).where(filter)
  end
  def filter
    arel = nil

    columns.each do |column|
      sv = params[column[:name]] || next
      this_arel =
        if column[:filter]
          column[:filter].call(sv)
        else
          column[:model].arel_table[column[:column_name]].matches("%#{sv}%")
        end
      if arel
        arel = arel.and(this_arel)
      else
        arel = this_arel
      end
    end
    arel
  end
=begin  
  def execute_filters(col)
    binding.pry
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
=end
  ## for elements/components
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
  end
end
