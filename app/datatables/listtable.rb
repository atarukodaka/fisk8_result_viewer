class Listtable
  attr_reader :collection, :columns
  def initialize(initial_collection, columns)
    @initial_collection = initial_collection
    @columns =
      case columns
      when Array
        columns.map {|d| [d, d]}.to_h
      else
        columns
      end
    @collection = nil
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

