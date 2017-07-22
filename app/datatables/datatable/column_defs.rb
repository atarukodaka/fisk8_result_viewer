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
################################################################
class Datatable::ColumnDef
  extend Property
  
  properties :name, :source
  properties :visible, :orderable, :searchable, default: true
  property :operator

  def initialize(name) # , datatable)
    @name = name.to_s
    #@datatable = datatable
    #@source = [datatable.records.table_name, @name].join('.')
  end
  def table_name
    source.split(/\./).first
  end
  def table_column
    source.split(/\./).last
  end
  def model
    table_name.classify.constantize
  end

  def operator
    @operator ||=
      begin
        orm_column = model.columns.find {|c| c.name == table_column}
        
        case orm_column.try(:type)
        when :integer, :float
          :eq
        else
          :matches
        end
      end
  end
end

################################################################
