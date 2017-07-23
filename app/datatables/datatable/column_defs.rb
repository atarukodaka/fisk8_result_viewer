class Datatable::ColumnDefs
  extend Forwardable
  def_delegators :@data, :[], :[]=, :keys, :values, :each, :map

  def initialize(columns, table_name: nil)
    @data = {}.with_indifferent_access
    columns.each do |col|
      @data[col] = Datatable::ColumnDef.new(col)
      @data[col].source = [table_name, col].compact.join('.')
    end
  end
  def sources=(hash)
    hash.map do|column, source|
      self[column.to_s].source = source
    end
  end
end
################################################################
class Datatable::ColumnDef
  extend Property
  
  properties :name, :source
  properties :visible, :orderable, :searchable, default: true
  property :operator

  def initialize(name)
    @name = name.to_s
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
