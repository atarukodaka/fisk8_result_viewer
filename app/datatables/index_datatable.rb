class IndexDatatable < AjaxDatatables::Datatable
  include AjaxDatatables::Datatable::ConditionBuilder

  def manipulate(records)
    super(records).where(build_conditions(filter_searching_nodes))
  end

  def filter_searching_nodes
    columns.select(&:searchable).map do |column|
      sv = params[column.name].presence || next
      { column_name: column.name, search_value: sv }
    end.compact
  end

  def default_settings
    super.merge(pageLength: 25, searching: true)
  end

  def default_model
    # @model ||= (self.class.to_s.split(/::/).last =~ /^([^:]*)Datatable/) ? $1.singularize.constantize : super
    @default_model ||= self.class.to_s.sub(/Datatable$/, '').singularize.constantize || super
  end
end
