module Datatable::Decoratable
  include Datatable::Manipulatable
  def decorate
    add_manipulator(->(r){ r.decorate })
    self
  end
end  

