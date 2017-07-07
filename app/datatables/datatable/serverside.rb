module Datatable::Serverside
  def manipulate_collection(col)
    super(col).order(order_sql).page(page).per(per)
  end
  def execute_filters(col)
    col = super(col)
    ## ajax serverside search
    return col if params[:columns].blank?
    
    # TODO: checkinjection
    params[:columns].each do |num, hash|
      column_name = hash[:data]  # TODO
      if (sv = hash[:search][:value].presence)
        #column = columns.select {|h| h[:name] == column_name}.first || raise
        column = columns.find_by_name(column_name) || raise
        col = col.where("#{column[:by]} like ?", "%#{sv}%")
      end
    end
    col
  end
  ## output
  def as_json(opts={})
    {
      iTotalRecords: collection.model.count,
      iTotalDisplayRecords: collection.total_count,
      data: collection.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end
  ## for paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  ## for sorting
  def order_sql
    return "" if params[:order].blank?
     params[:order].permit!.to_h.map do |_, hash|
      column = columns[hash[:column].to_i]
      #key = (column[:table]) ? [column[:table], column[:column_name]].join(".") : column[:column_name]
      [column[:by], hash[:dir]].join(' ')
    end
  end
end
