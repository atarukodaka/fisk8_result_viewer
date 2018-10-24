class StaticsDatatable < AjaxDatatables::Datatable
  def default_settings
    columns['no'].numbering = true if columns['no'].present?
    # super.merge(info: false, pagingType: 'simple', lengthChange: false, pageLength: 10)
    super.merge(info: false, paging: false, searching: false)
  end
end
