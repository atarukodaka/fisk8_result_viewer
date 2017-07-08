module Datatable::Serverside
  def manipulate_collection(col)
    #super(col).order(order_sql).page(page).per(per)
    super(col).where(ajax_filter).order(order_sql).page(page).per(per)
    
  end
  def ajax_filter
    arel = nil
    ## ajax serverside search
    return arel if params[:columns].blank?

    params[:columns].each do |num, hash|
      column_name = hash[:data]  # TODO
      if (sv = hash[:search][:value].presence)
        column = columns.find_by_name(column_name) || raise
        #col = col.where("#{column[:key]} like ?", "%#{sv}%")
        this_arel = column[:model].arel_table[column[:column_name]].matches("%#{sv}%")
        if arel
          arel = arel.and(this_arel)
        else
          arel = this_arel
        end
      end
    end
    arel
=begin    
    # TODO: checkinjection
    params[:columns].each do |num, hash|
      column_name = hash[:data]  # TODO
      if (sv = hash[:search][:value].presence)
        #column = columns.select {|h| h[:name] == column_name}.first || raise
        column = columns.find_by_name(column_name) || raise
        col = col.where("#{column[:key]} like ?", "%#{sv}%")
      end
    end
=end
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
     params[:order].permit!.to_h.map do |_, hash|  # TODO: each for columns
      column = columns[hash[:column].to_i]
      ["#{column[:model].table_name}.#{column[:column_name]}", hash[:dir]].join(' ')
    end
  end
end
