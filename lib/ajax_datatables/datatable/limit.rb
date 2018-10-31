module AjaxDatatables::Datatable::Limit
  MIN_LENGTH = 25
  MAX_LENGTH = 1_000
  def limit(number = MAX_LENGTH, offset = 0)
    @limit = (number.to_i.zero?) ? MIN_LENGTH : [number.to_i, MAX_LENGTH].min
    @offset = offset
    self.extend AjaxDatatables::Datatable::Limitable
    self
  end
end

module AjaxDatatables::Datatable::Limitable
  def manipulate(records)
    super(records).limit(@limit).offset(@offset)
  end
end
