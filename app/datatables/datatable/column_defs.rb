class Datatable::ColumnDefs
  extend Forwardable
  def_delegators :@data, :[], :[]=, :keys, :values

  def initialize(columns, table_name: nil)
    @data = {}.with_indifferent_access
    columns.each do |col|
      @data[col] = Datatable::ColumnDef.new(col)
      @data[col].source = [table_name, col].compact.join('.')
    end
  end
end
