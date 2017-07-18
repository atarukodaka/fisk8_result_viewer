class Datatable::ColumnDef
  def initialize(datatable)
    @datatable = datatable
  end
  
  def source(column)
    @datatable.sources[column.to_sym] || column.to_s
  end
  def hidden?(column)
    @datatable.hidden_columns.index(column.to_sym)
  end
end

