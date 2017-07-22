class Datatable::ColumnDef
  def initialize(name, datatable)
    @name = name
    @datatable = datatable
  end
  def name
    @name
  end
  def source
    @datatable.sources[name.to_sym]
  end
  def table_name
    source.split(/\./).first
  end
  def table_column
    source.split(/\./).last
  end
  def model
    table_name.classify.constantize
  end
  ################
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
