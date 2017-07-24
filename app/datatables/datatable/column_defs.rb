class Datatable::ColumnDefs
  extend Forwardable
  def_delegators :@data, :[], :[]=, :keys, :values, :each, :map

  def initialize(columns, datatable: )
    @data = {}.with_indifferent_access
    @datatable = datatable
    columns.each do |col|
      #@data[col.to_sym] = Datatable::ColumnDef.new(col, datatable: @datatable)
      @data[col.to_sym] = Datatable::ColumnDef.new(col, source: [@datatable.records.try(:table_name), col].compact.join('.'))
    end
  end
  def sources=(hash)
    hash.map do|column, source|
      self[column.to_sym].source = source
    end
  end
end
################################################################
class Datatable::ColumnDef
  extend Property
  
  properties :name, :source
  properties :visible, :orderable, :searchable, default: true
  property :numbering, false
  property :operator

  def initialize(name, source: nil)
    @name = name.to_s
    #@datatable = datatable
    @source = source || @name
  end
=begin
  def source
    @source ||= [@datatable.records.table_name, name].join('.')
  end
=end
  def table_name
    (source =~ /\./) ? source.split(/\./).first : ""
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
