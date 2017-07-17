class StaticsDatatable < Datatable
  def default_settings
    super.merge(info: false, pagingType: "simple", lengthChange: false)
#                columnDefs: [ {searchable: false, orderable: false, targets: "0"} ])
  end

  def render(view, locals: {})
    super(view, locals: locals.merge(numbering: true))
  end
end
