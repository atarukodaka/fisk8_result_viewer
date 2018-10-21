module AjaxDatatables::Datatable::ConditionBuilder
  def build_conditions(nodes)
    ## nodes: array of hash {column_name:, search_value:, operator:nil }
    nodes.map do |hash|
      column = columns[hash[:column_name]]
      table_field = column.table_field
      model = column.table_model || records.model
      sv = hash[:search_value]
      operator = hash[:operator] || column.operator ||
                 begin
                   column_type = model.columns.find { |c| c.name == table_field }.type
                   case column_type
                   when :integer, :float
                     :eq
                   when :boolean
                     :boolean
                   else
                     :matches
                   end
                 end

      ## create arel table for the searcing query
      arel = model.arel_table[table_field]
      if operator.class == Proc
        operator.call(arel)
      else
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
