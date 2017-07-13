module Datatable::Params
  attr_writer :params
  def params
    @params ||= {}
  end
  def set_params(prm)   # method chain
    @params = prm
    self
  end
end
