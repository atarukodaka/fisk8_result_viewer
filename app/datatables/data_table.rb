class DataTable < FilterTable
  def fetch_collection
    filter(@initial_collection).order(sort_sql).page(page).per(per)
  end
  def filter(col)
    filters.each do |key, pr|
      column_number = columns.keys.index(key)
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
    [sort_column, sort_direction].join(' ')
  end
  def sort_column
    columns.values[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
