module IndexDatatable::SeasonFilterable
  def filter_search_nodes
    nodes = super
    [{key: :season_from, column_name: 'season', operator: :gteq},
     {key: :season_to, column_name: 'season', operator: :lteq}].each do |item|
      if (sv = params[item[:key]].presence)
        nodes << { column_name: item[:column_name].to_s, search_value: sv, operator: item[:operator]}
      end
    end
    nodes
  end
end
