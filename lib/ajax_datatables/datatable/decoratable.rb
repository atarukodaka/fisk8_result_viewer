module AjaxDatatables::Datatable::Decoratable
  def decorate
    #add_manipulator(->(r){ r.decorate })
    self.extend AjaxDatatables::Datatable::Decorate
    self
  end
end  

module AjaxDatatables::Datatable::Decorate
  def manipulate(r)
    super(r).decorate
  end
end

