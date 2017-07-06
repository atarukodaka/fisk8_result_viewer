class ServersideManipulator < FilterManipulator
  attr_reader :columns
  
  def initialize(filters = {}, params = {}, columns: nil)
    super(filters, params)
    @columns = columns
  end
  def manipulate(col)
    execute_filters(super(col)).order(sort_sql).page(page).per(per)
  end

  def execute_filters(col)
    return col if params[:columns].blank?
    # ajax params
    filters.each do |key, pr|
      column_number = columns.names.index(key.to_s)
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
      key = (column[:table]) ? [column[:table], column[:column_name]].join(".") : column[:column_name]
      [key, hash[:dir]].join(' ')
    end
  end
end
