module AjaxDatatables::Datatable::Serverside
  def serverside
    self.extend AjaxDatatables::Datatable::Serversidable
  end
end

module AjaxDatatables::Datatable::Serversidable
  include AjaxDatatables::Datatable::ConditionBuilder

  ################
  ## for server-side ajax
  def manipulate(records)
    super(records).where(build_conditions(columns_searching_nodes)).order(serverside_ordering_sql)
  end

  ################
  ## searching
  def columns_searching_nodes
    return [] if params[:columns].blank?

    params.require(:columns).values.reject { |d| d[:searchable] == 'false' }.map do |item|
      sv = item[:search][:value].presence || next
      { column_name: item[:data], search_value: sv }
    end.compact
  end

  ################
  ## sorting
  def serverside_ordering_sql
    return nil if params[:order].blank?

    params.require(:order).values.reject { |d| d[:orderable] == 'false' }.map do |item|
      [columns[item[:column].to_i].source, item[:dir]].join(' ')
    end
  end

################
## json output
=begin
  def as_json(*args)
    self.decorate
    {
      iTotalRecords:        records.count,
      iTotalDisplayRecords: data.total_count,
      data:                 super.as_json(*args),
    }
  end
=end
end
