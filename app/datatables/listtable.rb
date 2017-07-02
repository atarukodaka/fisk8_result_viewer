class Listtable
  attr_reader :collection, :columns
  def initialize(initial_collection, columns)
    @initial_collection = initial_collection
    @columns = columns.map do |column|
      case column
      when Symbol, String
        {name: column.to_s, table: initial_collection.table_name, column_name: column.to_s}
      when Hash
        column[:column_name] ||= column[:name]
        column
      end
    end
=begin
    @columns = columns.map do |column|
      ary = column.to_s.split(/\./)
      {name: ary.last, table: ary[0..-2].join('.').presence || initial_collection.table_name}
    end
=end
    @collection = nil
  end

  def column_names
    @columns.map {|c| c[:name]}
  end
  def table_id
    "table_#{self.object_id}"
  end
  def collection
    @collection ||= fetch_collection
  end
  def fetch_collection
    @initial_collection
  end
end

