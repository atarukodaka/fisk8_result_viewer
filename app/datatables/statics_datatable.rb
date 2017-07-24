class StaticsDatatable < Datatable
  def initialize(*args)
    super(*args)
    self.options[:numbering_column_name] = "no"
  end
  def default_settings
    super.merge(info: false, pagingType: "simple", lengthChange: false, pageLength: 10)
#                columnDefs: [ {searchable: false, orderable: false, targets: "0"} ])
  end
end