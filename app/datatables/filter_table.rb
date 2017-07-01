class FilterTable < ListTable
  attr_reader :filters, :params
  def initialize(initial_collection, columns, filters: {}, params: {})
    super(initial_collection, columns)
    @filters = filters
    @params = params
  end
  def fetch_collection
    filter(@initial_collection)
  end
  def filter(col)
    filters.each do |key, pr|
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
end  
