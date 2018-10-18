class IndexDatatable < AjaxDatatables::Datatable
  class Filters
    class Filter < AjaxDatatables::Filter; end
    delegate :[], :each, :map, :reject, to: :@data
    attr_reader :data
    def initialize(ary = [])
      @data = ary
    end
  end

  include AjaxDatatables::Datatable::ConditionBuilder
  class Filter < AjaxDatatables::Filter; end ## shortcut purpose only

  def manipulate(records)
    super(records).where(build_conditions(filter_search_nodes))
  end

  def filter_search_nodes
    nodes = columns.select(&:searchable).map do |column|
      sv = params[column.name].presence
      (sv) ? { column_name: column.name, search_value: sv } : nil
    end.compact

    ## season
    if (season_from = params[:season_from].presence)
      nodes << { column_name: 'season', search_value: season_from, operator: :gteq }
    end

    if (season_to = params[:season_to].presence)
      nodes << { column_name: 'season', search_value: season_to, operator: :lteq }
    end
    nodes
  end

  def default_settings
    super.merge(pageLength: 25, searching: true)
  end
end
