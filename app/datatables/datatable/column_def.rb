class Datatable::ColumnDef
  def initialize(datatable)
    @datatable = datatable
  end
  
  def source(column)
    @datatable.sources[column.to_sym].presence ||
      if (model = @datatable.records.try(:model))
        [model.table_name, column.to_s].join('.')
      else
        column.to_s
      end
  end
=begin
  def hidden?(column)
    @datatable.hidden_columns.index(column.to_sym)
  end
=end
end

