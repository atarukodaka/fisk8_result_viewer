module Datatable::Searchable
  def searching_sql(nodes)   ## nodes: array of hash {table_column:, search_value: }
    nodes.map do |hash|
      table_column = column_def(hash[:column_name]).table_column
      model = column_def(hash[:column_name]).model
      operator = params["#{table_column}_operator"].to_s.to_sym
      model.searching_arel_table_node(table_column, hash[:search_value], operator: operator)
    end.reduce(&:and)
  end


end
