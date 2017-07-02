class Datatable < Listtable
  attr_accessor :filters, :params, :default_order, :paging
  def initialize(initial_collection, columns, filters: {}, params: {}, default_order: nil, paging: false)
    super(initial_collection, columns)
    @filters = filters
    @params = params
    @default_order = default_order
    @paging = paging
  end
  def fetch_collection
    col = filter(super)
    col = col.order(sort_sql) if sort_sql.present?
    (paging) ? col.page(page).per(per) : col
  end
  def filter(col)
    filters.each do |key, pr|
      #column_number = columns.keys.index(key)
      column_number = column_names.index(key.to_s)
      v = params["sSearch_#{column_number}"].presence || params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
  
  ## for paging
  def page
    params[:iDisplayStart].to_i / per + 1
  end
  def per
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
  
  ## for sorting
  def sort_sql
    return "" if params[:iSortCol_0].blank?
    [sort_column, sort_direction].join(' ')
  end
  def sort_column
    column = columns[params[:iSortCol_0].to_i]
    [column[:table], column[:column_name]].join('.')
    #columns.values[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
