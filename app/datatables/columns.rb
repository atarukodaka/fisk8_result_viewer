class Column
  extend Forwardable
  def_delegator :@data, :[]
  def initialize(arg)
    @data =
      case arg
      when Symbol, String
        { name: arg.to_s }
      when Hash
        arg.symbolize_keys
      end
    @data[:name] = @data[:name].to_s
    @data[:key] ||= @data[:name].to_s
  end
end
################################################################
class Columns
  extend Forwardable
  def_delegators :@columns, :map, :[], :select, :each
  
  attr_reader :names
  def initialize(columns = [])
    @columns = columns.map {|column| Column.new(column) }
  end
  def names
    @columns.map {|c| c[:name]}
  end
  def find_by_name(name)
    @columns.select {|c| c[:name] == name }.first
  end
end
