class IndexDatatable < AjaxDatatables::Datatable
  include AjaxDatatables::Datatable::ConditionBuilder

  class Filters < AjaxDatatables::Filters
    OPERATORS = { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }.freeze
  end

  ################
  def source_mappings
    {
      skater_name: 'skaters.name',
      nation:            'skaters.nation',
      category_type_name: 'category_types.name',

      competition_name:  'competitions.name',
      competition_short_name:  'competitions.short_name',
      competition_class: 'competitions.competition_class',
      competition_type:  'competitions.competition_type',

      team:              'categories.team',
      seniority:         'categories.seniority',
      segment_name:      'segments.name',
      segment_type:      'segments.segment_type',
      season:            'competitions.season',

      score_name:              'scores.name',
    }
  end
  def manipulate(records)
    super(records).where(build_conditions(filter_searching_nodes)).order(ordering_sql)
  end

  def filter_searching_nodes
    return [] if view_context.nil?

    columns.select(&:searchable).map do |column|
      sv = params[column.name].presence || next
      { column_name: column.name, search_value: sv }
    end.compact
  end

  def filters
    @filters ||= "#{default_model.to_s.pluralize}Datatable::Filters".constantize.new(datatable: self)
  rescue NameError
    nil
  end

  def ordering_sql
    return nil if view_context.nil?

    if (column = columns[params[:sort_column]])
      direction = (params[:sort_direction] == 'desc') ? :desc : :asc
      ["#{column.source} #{direction}"]
    end
  end

  def default_settings
    super.merge(pageLength: 25, searching: true)
  end

  def default_model
    @default_model ||= self.class.to_s.sub(/Datatable$/, '').classify.constantize || super
  end
end
################
