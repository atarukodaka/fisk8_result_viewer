module Datatable::Manipulatable
  def data
    @manipulated_data ||= manipulate(@data)
  end
  def manipulators
    @manipulators ||= []
  end
  def add_manipulator(f)
    manipulators << f
    self
  end
  def manipulate(data)
    manipulators.reduce(data){|d, m| m.call(d)}
  end
end  
