class Listtable < Datatable
  def render(partial: "listtable", locals: {}, view_context: nil)
    super(partial: partial, locals: locals)
    #view_context ||= @view_context
    #view_context.render(partial: partial, locals: {table: self }.merge(locals)) and return false
  end
  
  def as_json(opts={})
    data.as_json(only: columns)
  end
end
