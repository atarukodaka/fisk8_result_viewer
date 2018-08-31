module AjaxDatatables::Datatable::Decoratable
  def decorate
    self.extend AjaxDatatables::Datatable::Decorate
    self
  end
end  

module AjaxDatatables::Datatable::Decorate
  def manipulate(r)
    super(r).decorate
  end
end

