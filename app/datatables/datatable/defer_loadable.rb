module Datatable::DeferLoadable
  def defer_load
    self.extend Datatable::DeferLoading
    self
  end
end
module Datatable::DeferLoading
  def settings
    super.merge(deferLoading: records.count)
  end
  def manipulate(r)
    super(r)
      .order(default_orders.map {|column, dir| [columns[column].source, dir].join(' ')})
      .limit(settings[:pageLength] || 25).decorate


  end
end
