class Listtable < Datatable
  def render(view, partial: "listtable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  
  def as_json(opts={})
    data.as_json(only: columns)
  end
end
