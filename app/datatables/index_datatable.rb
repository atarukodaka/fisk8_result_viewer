class IndexDatatable < AjaxDatatables::Datatable
  include AjaxDatatables::Datatable::ConditionBuilder

  def manipulate(records)
    super(records).where(build_conditions(filter_search_nodes))
  end

  def filter_search_nodes
    nodes = columns.select(&:searchable).map do |column|
      sv = params[column.name].presence
      (sv) ? { column_name: column.name, search_value: sv } : nil
    end.compact

=begin
    [{key: :season_from, column_name: 'season', operator: :gteq},
     {key: :season_to, column_name: 'season', operator: :lteq}].each do |item|
      if (sv = params[item[:key]].presence)
        nodes << { column_name: item[:column_name].to_s, search_value: sv, operator: item[:operator]}
      end
    end
=end
    nodes
  end

  def default_settings
    super.merge(pageLength: 25, searching: true)
  end
end
