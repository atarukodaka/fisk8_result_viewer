class Listtable; end

module Listtable::Manipulate
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

module Listtable::Decorate
  def decorate
    add_manipulator(->(r){ r.decorate })
  end
end  

class Listtable
  attr_reader :columns
  include Listtable::Manipulate
  include Listtable::Decorate

  def initialize(data, only: nil)
    @data = data
    @columns = (only) ? only : data.column_names
  end
  def data
    manipulate(@data)
  end
  def column_names
    @columns.map(&:to_s)
  end
  def render(view, partial: "listtable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  
  def as_json(opts={})
    data
  end
end
