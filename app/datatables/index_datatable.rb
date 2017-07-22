class IndexDatatable < Datatable
  include Datatable::Searchable  
  def manipulate(d)
    super(d).where(searching_sql(filter_search_nodes))
  end
  def filter_search_nodes
    
    node = searchable_columns.map(&:to_s).map do |column_name|
      next unless sv = params[column_name].presence
      {column_name: column_name, search_value: sv}
    end.compact
  end
end
