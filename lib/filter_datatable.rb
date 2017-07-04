class FilterDatatable < Datatable
  include Datatable::Filterable
  def initialize(initial_collection, columns, filters: {}, params: {},  options: {})
    super(initial_collection, columns,  options: {})
    @filters = filters
    @params = params
  end
end
