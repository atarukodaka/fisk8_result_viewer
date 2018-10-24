module AjaxDatatables::Datatable::Paging
  def serverside
    self.extend AjaxDatatables::Datatable::Pageable
  end
end

module AjaxDatatables::Datatable::Pageable
  ################
  ## paging
  def manipulate(records)
    records.page(page).per(per)
  end
  def page
    params[:start].to_i / per + 1
  end

  def per
    (params[:length].to_i.positive?) ? params[:length].to_i : 10
  end
end

