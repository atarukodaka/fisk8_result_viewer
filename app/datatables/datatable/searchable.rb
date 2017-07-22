module Datatable::Searchable
  def searching_sql(nodes)   ## nodes: array of hash {table_column:, search_value: }
    nodes.map do |hash|
      column_def = column_defs[hash[:column_name]]
      table_column = column_def.table_column
      model = column_def.model
      sv = hash[:search_value]      
      operator = params["#{table_column}_operator"].presence || column_def.operator

      ## create arel table for the searcing query
      arel = model.arel_table[table_column]
      case operator.to_sym
      when :eq, :lt, :lteq, :gt, :gteq
        arel.send(operator, sv)
      else
        arel.matches("%#{sv}%")
      end
    end.reduce(&:and)
  end
end
