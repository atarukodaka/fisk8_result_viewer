class Datatable::ColumnDefs
  extend Forwardable
  def_delegators :@data, :[], :[]=, :keys, :values, :each, :map

  def initialize(columns, datatable: )
    @data = {}.with_indifferent_access
    @datatable = datatable

    columns.each do |col|
      column_def = create_column_def(col)
      @data[column_def.name.to_sym] = column_def
    end
  end
  def []=(key, value)
    @data[key] = 
      case value
      when Hash
        create_column_def(value)
      when Datatable::ColumnDef
        value
      else
        raise
      end
  end
  def sources=(hash)
    hash.map do|column, source|
      self[column.to_sym].source = source
    end
  end
  ################
  protected
=begin  
  def table_name
    @datatable.records.try(:table_name)
  end
=end
  def create_column_def(col)
    column_def = Datatable::ColumnDef.new
    case col
    when Hash
      acceptable_keys = [:name, :source, :searchable, :orderable, :numbering]
      col.each do |key, value|
        if acceptable_keys.include?(key)
          column_def.send(key, value)
        else
          raise "no such key: #{key}"
        end
      end
      raise "column name missing" if col[:name].blank?
    else
      column_def.name = col.to_s
    end
    #column_def.source ||= [table_name.presence, column_def.name].compact.join('.')
    column_def.source ||= column_def.name
    column_def
  end
end
################################################################
class Datatable::ColumnDef
  extend Property
  
  properties :name, :source, default: nil
  properties :visible, :orderable, :searchable, default: true
  property :numbering, false
#  property :operator

  def initialize(name=nil)
    @name = name.to_s
  end

  def table_name
    (source =~ /\./) ? source.split(/\./).first : ""
  end
  def table_column
    source.split(/\./).last
  end
  def model
    (table_name.present?) ? table_name.classify.constantize : nil
  end

=begin
  def operator
    @operator ||=
      begin
        #orm_column = model.columns.find {|c| c.name == table_column}
        column_type = (model) ? model.columns.find{|c| c.name == table_column}.type : :string
        
        #case orm_column.try(:type)
        case column_type
        when :integer, :float
          :eq
        else
          :matches
        end
      end
  end
=end
end

################################################################
