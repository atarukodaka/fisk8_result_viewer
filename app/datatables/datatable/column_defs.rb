class Datatable::ColumnDefs
  extend Forwardable
  def_delegators :@data, :[], :[]=, :keys, :values

  def initialize(columns, datatable)
    @datatable = datatable
    @data = {}.with_indifferent_access
    columns.each do |col|
      @data[col] = Datatable::ColumnDef.new(col)   # , @datatable)
      @data[col].source = [@datatable.records.table_name, col].join('.')
    end
  end
end
