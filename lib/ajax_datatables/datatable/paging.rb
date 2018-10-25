module AjaxDatatables::Datatable::Paging
  def paging
    self.extend AjaxDatatables::Datatable::Pageable
  end
end

module AjaxDatatables::Datatable::Pageable
  MAX_LENGTH = 1000

  def manipulate(records)
    super(records).page(page).per(per)
  end
  def page
    params[:start].to_i / per + 1
  end

  def per
    (params[:length].to_i.positive?) ? [params[:length].to_i, MAX_LENGTH].min : 10
  end
end

