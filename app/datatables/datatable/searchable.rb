module Datatable::Searchable
  def searching_sql(nodes)   ## nodes: array of hash {table_column:, search_value: }
    nodes.map do |hash|
      table_column = column_def(hash[:column_name]).table_column
      model = column_def(hash[:column_name]).model
      sv = hash[:search_value]      
      operator = params["#{table_column}_operator"].to_s.to_sym

      ## create arel table for the searcing query
      arel = model.arel_table[table_column]
      case operator
      when :eq, :lt, :lteq, :gt, :gteq
        arel.send(operator, sv)
      else
        arel.matches("%#{sv}%")
      end
    end.reduce(&:and)
  end
end
