module ServersideDatatableModule
  def fetch_collection
    super.order(sort_sql).page(page).per(per)
  end

  def execute_filters(col)
    col = super(col)
    # ajax params
    filters.each do |key, pr|
      column_number = column_names.index(key.to_s)
      v = params["sSearch_#{column_number}"]
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
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
