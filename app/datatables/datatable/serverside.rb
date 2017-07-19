module Datatable::Serverside
  ################################################################
  ## for server-side ajax
  ## searching
  def search_sql
    return "" if params[:columns].blank?

    a = params.require(:columns).values.map {|item|
      sv = item[:search][:value].presence || next
      column_name = item[:data]
      next unless column_defs.searchable(column_name)

      table_name, table_column = column_defs.source(column_name).split(/\./)
      model = table_name.classify.constantize
      condition = column_defs.condition(column_name) || :eq
      arel_table = model.arel_table[table_column]

      case condition
      when :eq
        arel_table.eq(sv)
      when :matches
        arel_table.matches("%#{sv}%")
      end
    }.compact.reduce(&:and)

    a
  end
  ################
  ## sorting
  def order_sql
    return "" if params[:order].blank?

    params.require(:order).values.map do |hash|
      column_name = columns[hash[:column].to_i]
      key = column_defs.source(column_name)
      [key, hash[:dir]].join(' ')
    end
  end
  ################
  ## paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  ################
  ## json output
  def as_json(opts={})
    new_data = data.where(search_sql).order(order_sql).page(page).per(per)    
    {
      iTotalRecords: new_data.model.count,
      iTotalDisplayRecords: new_data.total_count,
      data: new_data.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end
end
