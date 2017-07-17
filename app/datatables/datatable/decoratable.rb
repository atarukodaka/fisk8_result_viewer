module Datatable::Decoratable
  def decorate
    add_manipulator(->(r){ r.decorate })
    self
  end
end  

