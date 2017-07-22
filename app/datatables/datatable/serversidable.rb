module Datatable::Serversidable
  def serverside
    self.extend Datatable::Serverside
  end
end

module Datatable::Serverside
  ## for server-side ajax

  def manipulate(r)
    r = super(r).where(search_sql).order(order_sql).page(page).per(per)
  end
  
  ################
  ## searching
  def search_sql
    return "" if params[:columns].blank?

    params.require(:columns).values.map {|item|
      next if item[:searchable] == "false"
      sv = item[:search][:value].presence || next
      column_name = item[:data]
      #next unless column_defs.searchable(column_name)

      searching_arel_table_node(column_name, sv)
    }.compact.reduce(&:and)
  end
  ################
  ## sorting
  def order_sql
    return "" if params[:order].blank?

    params.require(:order).values.map do |hash| # TODO: chk orderable of each colmuns
      column_name = columns[hash[:column].to_i]
      #key = column_defs.source(column_name)
      key = sources[column_name.to_sym]
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
    self.decorate
    {
      iTotalRecords: records.count,
      iTotalDisplayRecords: data.total_count,
      #data: expand_data(data.decorate)
      data: super.as_json
    }
  end
end
