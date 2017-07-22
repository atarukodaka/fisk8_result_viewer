class Datatable::ColumnDef
  extend Property
  
  properties :name, :source
  properties :visible, :orderable, :searchable, default: true
  property(:operator){
    orm_column = model.columns.find {|c| c.name == table_column}
    
    case orm_column.try(:type)
    when :integer, :float
      :eq
    else
      :matches
    end
  }
    
  def initialize(name, datatable)
    @name = name.to_s
    @datatable = datatable
    @source = [datatable.records.table_name, @name].join('.')
  end
=begin
  def name
    @name
  end
  def source
    @datatable.sources[name.to_sym]
  end
=end
  def source=(src)
    @source = src
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
  ################
=begin  
  def visible
    (@datatable.hidden_columns.index(@name.to_sym)) ? false : true
  end
  def orderable
    (@datatable.orderable_columns.index(@name.to_sym)) ? true : false
  end
  def searchable
    (@datatable.searchable_columns.index(@name.to_sym)) ? true : false
  end
=end
end

################################################################
