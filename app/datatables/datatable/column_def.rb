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
  def table_name
    source.split(/\./).first
  end
  def table_column
    source.split(/\./).last
  end
  def model
    table_name.classify.constantize
  end
end

################################################################
