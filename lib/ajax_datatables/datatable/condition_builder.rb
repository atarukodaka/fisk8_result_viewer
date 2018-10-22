module AjaxDatatables::Datatable::ConditionBuilder
  def build_conditions(nodes)
    ## nodes: array of hash {column_name:, search_value:, operator:nil }
    nodes.map do |hash|
      column = columns[hash[:column_name]]
      operator = hash[:operator] || column.operator ||
                 begin
                   case column.table_model.columns.find { |c| c.name == column.table_field }.type
                   when :integer, :float then :eq
                   when :boolean then :boolean
                   else; :matches
                   end
                 end

      ## create arel table for the searcing query
      arel = column_table.model.arel_table[column.table_field]
      if operator.class == Proc
        operator.call(arel)
      else
        sv = hash[:search_value]
        case operator.to_sym
        when :eq, :lt, :lteq, :gt, :gteq
          arel.send(operator, sv)
        when :boolean
          arel.send(:eq, ActiveRecord::Type::Boolean.new.cast(sv))
        else
          arel.matches("%#{sv}%")
        end
      end
    end.reduce(&:and)
  end
end
