class Listtable < Datatable
  def render(partial: "listtable", locals: {})
    super(partial: partial, locals: locals)
  end
  
  def as_json(opts={})
    data.as_json(only: columns)
  end
end
