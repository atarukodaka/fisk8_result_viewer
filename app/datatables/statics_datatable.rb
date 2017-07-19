class StaticsDatatable < Datatable
  def initialize(*args)
    super(*args)
    self.numbering = :no
  end
  def default_settings
    super.merge(info: false, pagingType: "simple", lengthChange: false)
#                columnDefs: [ {searchable: false, orderable: false, targets: "0"} ])
  end
end
