
class Listtable
  attr_reader :data, :column_names
  def initialize(data, column_names = [])
    @data = data
    @column_names = column_names
  end

  def render(view, partial: "list_table", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end

  def as_json(opts={})
    data
  end
end
