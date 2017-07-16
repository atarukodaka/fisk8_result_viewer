module Datatable::Manipulatable
  def data
    @manipulated_data ||= manipulate(@data)
  end
  def manipulate(data)
    manipulators.reduce(data){|d, m| m.call(d)}
  end
  def manipulators
    @manipulators ||= []
  end
  def add_manipulator(f)
    manipulators << f
    self
  end
end  
