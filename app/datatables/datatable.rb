class Datatable
  attr_accessor :collection, :columns, :options


  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(initial_collection, columns,  options: {})
    @initial_collection = initial_collection
    @columns = columns.map do |column|
      case column
      when Symbol, String
        {
          name: column.to_s,
          table: initial_collection.table_name,
          column_name: column.to_s
        }
      when Hash
        column[:column_name] ||= column[:name]
        column
      end
    end
    @options = options
  end

  def add_option(key, value)
    @options[key] = value
    self
  end
  def fetch_collection
    @initial_collection
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
end

################################################################
