module AjaxDatatables::Datatable::Search
  #  def searching_sql(nodes)   ## nodes: array of hash {column_name:, search_value:, operator:nil }
  def build_conditions_by_nodes(nodes)
    nodes.map do |hash|
      column = columns[hash[:column_name]]
      table_field = column.table_field
      model = column.model || records.model
      sv = hash[:search_value]
      operator = hash[:operator] || column.operator ||
                 begin
                   column_type = model.columns.find {|c| c.name == table_field}.type
                   case column_type
                   when :integer, :float
                     :eq
                   else
                     :matches
                   end
                 end
      
      ## create arel table for the searcing query
      arel = model.arel_table[table_field]
      case operator.to_sym
      when :eq, :lt, :lteq, :gt, :gteq
        arel.send(operator, sv)
      else
        arel.matches("%#{sv}%")
      end
    end.reduce(&:and)
  end
end
