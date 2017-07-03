class FilterDatatable < Datatable
  attr_accessor :filters, :params

  def initialize(initial_collection, columns, filters: {}, params: {},  options: {})
    super(initial_collection, columns,  options: {})
    @filters = filters
    @params = params
  end

  def fetch_collection
    execute_filters(@initial_collection)
  end
  def add_filters(hash)
    hash.each {|k, v| add_filter(k, v)}
    self
  end
  def add_filter(key, filter)
    @filters[key] = filter
    self
  end

  def execute_filters(col)
    # input params
    filters.each do |key, pr|
      column_number = column_names.index(key.to_s)
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
end
