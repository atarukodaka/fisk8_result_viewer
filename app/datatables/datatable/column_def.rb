class Datatable::ColumnDef
  def initialize(name, datatable)
    @name = name
    @datatable = datatable
  end
  def visible
    (@datatable.hidden_columns.index(@name.to_sym)) ? false : true
  end
  def orderable
    (@datatable.orderable_columns.index(@name.to_sym)) ? true : false
  end
  def searchable
    (@datatable.searchable_columns.index(@name.to_sym)) ? true : false
  end
end

################################################################
