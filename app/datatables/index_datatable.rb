class IndexDatatable < Datatable
  include Datatable::Searchable
  
  def manipulate(r)
    super(r).where(searching_sql(filter_search_nodes))
  end
  def filter_search_nodes
    column_defs.values.select(&:searchable).map do |column|
      next unless sv = params[column.name].presence
      {column_name: column.name, search_value: sv}
    end.compact
  end
end
