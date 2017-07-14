class Listtable
  attr_reader :columns
  def initialize(data, only: nil)
    @data = data
    #@column_names = column_names || data.keys
    @columns = (only) ? only : data.column_names
    @manipulators = []
  end
  def add_manipulator(f)
    @manipulators ||= []
    @manipulators << f
  end
  def decorate
    @manipulators << ->(r){ r.decorate }
    self
  end
  def data
    @manipulators.reduce(@data){|data, m| m.call(data)}
  end
  def render(view, partial: "listtable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  
  def as_json(opts={})
    data
  end
end
