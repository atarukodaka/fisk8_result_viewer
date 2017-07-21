module Datatable::DeferLoadable
  def defer_load
    self.extend Datatable::DeferLoading
  end
end
module Datatable::DeferLoading
  def default_setting
    super.merge(deferLoading: records.count)
  end
  def manipulate(r)
    super(r).limit(settings[:pageLength] || 25).decorate
  end
end
