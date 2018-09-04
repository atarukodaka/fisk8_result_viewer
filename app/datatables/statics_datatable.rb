class StaticsDatatable < AjaxDatatables::Datatable
  def default_settings
#    columns["no"].numbering = true
    super.merge(info: false, pagingType: "simple", lengthChange: false, pageLength: 10)
#                columnDefs: [ {searchable: false, orderable: false, targets: "0"} ])
  end
end
