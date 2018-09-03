class IndexDatatable < AjaxDatatables::Datatable
  include AjaxDatatables::Datatable::Search
  
  def manipulate(r)
    super(r).where(searching_sql(filter_search_nodes))
  end
  
  def filter_search_nodes
    nodes = columns.select(&:searchable).map do |column|
      sv = params[column.name].presence
      (sv) ? {column_name: column.name, search_value: sv} : nil
    end.compact

    ## season
    if (season_from = params[:season_from].presence)
      nodes << {column_name: "season", search_value: season_from, operator: :gteq}
    end

    if (season_to = params[:season_to].presence)
      nodes << {column_name: "season", search_value: season_to, operator: :lteq}
    end
    nodes
  end

  def default_settings
    super.merge( pageLength: 25 )
  end
end
