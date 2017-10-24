module Datatable::Serversidable
  def serverside
    self.extend Datatable::Serverside
  end
end

module Datatable::Serverside
  include Datatable::Searchable
  
  ################
  ## for server-side ajax
  def manipulate(r)
    super(r).where(searching_sql(columns_searching_nodes)).order(order_sql).page(page).per(per)
  end
  
  ################
  ## searching
  def columns_searching_nodes
    return [] if params[:columns].blank?

    params.require(:columns).values.map {|item|
      next if item[:searchable] == "false"
      sv = item[:search][:value].presence || next
      { column_name: item[:data], search_value: sv }
    }.compact
  end
  ################
  ## sorting
  def order_sql
    return "" if params[:order].blank?

    params.require(:order).values.map do |item|
      next if item[:orderable] == "false"

      [columns[item[:column].to_i].source, item[:dir]].join(' ')
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
  def as_json(*args)
    self.decorate
    {
      iTotalRecords: records.count,
      iTotalDisplayRecords: data.total_count,
      data: super.as_json(*args),
    }
  end
end
