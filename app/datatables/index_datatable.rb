class IndexDatatable < AjaxDatatables::Datatable
  include AjaxDatatables::Datatable::ConditionBuilder

  class Filters < AjaxDatatables::Filters; end
=begin
  def manipulate(records)
    super(records)
    super(records).where(build_conditions(filter_searching_nodes))
  end

  def filter_searching_nodes
    columns.select(&:searchable).map do |column|
      sv = params[column.name].presence || next
      { column_name: column.name, search_value: sv }
    end.compact
  end
=end
  def filters
    @filters ||= "#{default_model.to_s.pluralize}Datatable::Filters".constantize.new(datatable: self)
  rescue NameError
    nil
  end

  def default_settings
    super.merge(pageLength: 25, searching: true)
  end

  def default_model
    @default_model ||= self.class.to_s.sub(/Datatable$/, '').classify.constantize || super
  end
end
################
