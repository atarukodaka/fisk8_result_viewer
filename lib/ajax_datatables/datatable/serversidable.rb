module AjaxDatatables::Datatable::Serversidable
  def serverside
    self.extend AjaxDatatables::Datatable::Serverside
  end
end

module AjaxDatatables::Datatable::Serverside
  include AjaxDatatables::Datatable::ConditionBuilder

  ################
  ## for server-side ajax
  def manipulate(records)
    super(records).where(build_conditions(columns_searching_nodes)).order(sorting_sql).page(page).per(per)
  end

  ################
  ## searching
  def columns_searching_nodes
    return [] if params[:columns].blank?

    params.require(:columns).values.map { |item|
      next if item[:searchable] == 'false'

      sv = item[:search][:value].presence || next
      { column_name: item[:data], search_value: sv }
    }.compact
  end

  ################
  ## sorting
  def sorting_sql
    return '' if params[:order].blank?

    params.require(:order).values.map do |item|
      next if item[:orderable] == 'false'

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
      iTotalRecords:        records.count,
      iTotalDisplayRecords: data.total_count,
      data:                 super.as_json(*args),
    }
  end
end
