module Datatable::Params
  #
  # extension for Datatable class for which requires params
  #
  # usage:
  #
  #   Datatable.new(User.all).extend(Datatable::Params).add_params(params)
  #
  #include Property

  #property :params
  #attr_writer :params
  def params
    @params ||= {}
  end
  def set_params(prm)   # method chain
    @params = prm
    self
  end
end
