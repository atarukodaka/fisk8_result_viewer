class IndexDatatable < Datatable
  include Datatable::Searchable
  
  def manipulate(r)
    super(r).where(searching_sql(filter_search_nodes))
  end
  def filter_search_nodes
    nodes = columns.select(&:searchable).map do |column|
      next unless sv = params[column.name].presence
      {column_name: column.name, search_value: sv}
    end.compact

    if season_from = params[:season_from].presence
      nodes << {column_name: "season", search_value: season_from, operator: :gteq}
    end

    if season_to = params[:season_to].presence
      nodes << {column_name: "season", search_value: season_to, operator: :lteq}
    end
    nodes
  end
end
