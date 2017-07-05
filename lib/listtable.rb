
class Listtable
  attr_reader :data, :column_names
  def initialize(data, column_names = nil)
    @data = data
    @column_names = column_names || data.keys
  end

  def render(view, partial: "listtable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end

  def as_json(opts={})
    data
  end
end
