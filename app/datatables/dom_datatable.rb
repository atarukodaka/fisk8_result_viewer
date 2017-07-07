class DomDatatable < Datatable
  def initialize(collection, columns)
    @collection = collection
    @columns = Columns.new(columns)
  end
end
