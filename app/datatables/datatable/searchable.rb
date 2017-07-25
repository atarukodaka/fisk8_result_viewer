module Datatable::Searchable
  def searching_sql(nodes)   ## nodes: array of hash {column_name:, search_value: }
    nodes.map do |hash|
      column_def = column_defs[hash[:column_name]]
      table_field = column_def.table_field
      model = column_def.model || records.model
      sv = hash[:search_value]      
      operator = params["#{hash[:column_name]}_operator"].presence ||
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
