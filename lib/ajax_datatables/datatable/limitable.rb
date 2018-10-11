module AjaxDatatables::Datatable::Limitable
  def limit(number = 5_000)
    @limit = number
    self.extend AjaxDatatables::Datatable::Limit
  end
end

module AjaxDatatables::Datatable::Limit
  def manipulate(records)
    super(records).limit(@limit).offset(params[:offset].to_i || 0)
  end
end
