module Datatable::TableKeys

  def table_key(column)
    @table_keys ||= {}
    @table_keys[column.to_sym] || column.to_s
  end
end
