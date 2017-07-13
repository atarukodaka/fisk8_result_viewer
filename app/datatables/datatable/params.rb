module Datatable::Params
  attr_writer :params
  def params
    @params ||= {}
  end
end
