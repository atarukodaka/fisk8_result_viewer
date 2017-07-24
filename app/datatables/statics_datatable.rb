class StaticsDatatable < Datatable
  def initialize(*args)
    super(*args)
    #self.options[:numbering_column_name] = "no"
    #column_defs[:no].numbering = "true"
  end
  def default_settings
    #column_defs["no"].numbering = true
    super.merge(info: false, pagingType: "simple", lengthChange: false, pageLength: 10)
#                columnDefs: [ {searchable: false, orderable: false, targets: "0"} ])
  end
end
