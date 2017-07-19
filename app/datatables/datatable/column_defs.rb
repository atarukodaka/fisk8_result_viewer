class Datatable::ColumnDefs
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
  def condition(column)
    :matches
  end
  def searchable(column)
    @datatable.searchable_columns.index(column.to_sym).present?
  end
=begin
  def hidden?(column)
    @datatable.hidden_columns.index(column.to_sym)
  end
=end
end

