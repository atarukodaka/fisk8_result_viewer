module Datatable::Params
  #
  # extension for Datatable class for which requires params
  #
  # usage:
  #
  #   Datatable.new(User.all).extend(Datatable::Params).add_params(params)
  #
  extend Property

  property :params, {}
end
