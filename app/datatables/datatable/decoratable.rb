module Datatable::Decoratable
  def decorate
    #add_manipulator(->(r){ r.decorate })
    self.extend Datatable::Decorate
    self
  end
end  

module Datatable::Decorate
  def manipulate(r)
    r.decorate
  end
end

