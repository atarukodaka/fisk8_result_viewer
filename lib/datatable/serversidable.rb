module Datatable::Serversidable
  def fetch_collection
    super.order(sort_sql).page(page).per(per)
  end

  def execute_filters(col)
    col = super(col)
    return col if params[:columns].blank?
    # ajax params
    filters.each do |key, pr|
      column_number = column_names.index(key.to_s)
      #v = params["sSearch_#{column_number}"]
      h = params[:columns][column_number.to_s]
      next if h.nil?
      v = h[:search][:value]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
  
  ## for paging
  def page
    #params[:iDisplayStart].to_i / per + 1
    params[:start].to_i / per + 1
  end
  def per
    #params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  ## for sorting
  def sort_sql
    return "" if params[:order].blank?
    #return "" if params[:iSortCol_0].blank?
    #params[:order].permit!.map {|item|
    #params.require(:order).to_h.map {|item|
     params[:order].permit!.to_h.map do |_, hash|
      column = columns[hash[:column].to_i]
      key = [column[:table], column[:column_name]].join(".")
      [key, hash[:dir]].join(' ')
    end
  end
  def sort_column(i)
    #column = columns[params[:iSortCol_0].to_i]
    column = columns[params[:order][i.to_s][:column].to_i]
    [column[:table], column[:column_name]].join('.')
  end
  def sort_direction(i)
    #params[:sSortDir_0] == "desc" ? "desc" : "asc"
    (params[:order][i.to_s][:dir] == "desc") ? "desc" : "asc"
  end
end
