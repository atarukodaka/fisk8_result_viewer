module AjaxDatatables::Datatable::DeferLoad
  def defer_load
    self.extend AjaxDatatables::Datatable::DeferLoadable
    self
  end
end

module AjaxDatatables::Datatable::DeferLoadable
  def settings
    super.merge(deferLoading: records.count)
  end

  def manipulate(records)
    super(records)
      .order(default_orders.map { |column, dir| [columns[column].source, dir].join(' ') })
      .limit(settings[:pageLength] || 25).decorate
  end
end
