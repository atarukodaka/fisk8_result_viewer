class Listtable < AjaxDatatables::Datatable
  def render(partial: 'listtable', locals: {})
    super(partial: partial, locals: locals)
  end

=begin
  def as_json(_opts = {})
    data.as_json(only: column_names)
  end
=end
end
