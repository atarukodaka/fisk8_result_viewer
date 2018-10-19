module AjaxDatatables::Datatable::Decorate
  def decorate
    self.extend AjaxDatatables::Datatable::Decoratable
    self
  end
end

module AjaxDatatables::Datatable::Decoratable
  def manipulate(records)
    super(records).decorate
  end
end
