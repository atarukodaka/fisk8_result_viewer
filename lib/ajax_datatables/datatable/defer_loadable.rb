module AjaxDatatables::Datatable::DeferLoadable
  def defer_load
    self.extend AjaxDatatables::Datatable::DeferLoading
    self
  end
end
module AjaxDatatables::Datatable::DeferLoading
  def settings
    super.merge(deferLoading: records.count)
  end

  def manipulate(records)
    super(records)
      .order(default_orders.map { |column, dir| [columns[column].source, dir].join(' ') })
      .limit(settings[:pageLength] || 25).decorate
  end
end
