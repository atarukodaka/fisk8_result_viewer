class Column
  # 
  def initialize(arg)
    @data =
      case arg
      when Symbol, String
        { name: arg.to_s }
      when Hash
        arg.symbolize_keys
      end
  end

  def name
    @data[:name].to_s
  end
  def table
    @data[:table].to_s
  end
  def key
    [table, column_name].reject(&:blank?).join('.')
  end
  def column_name
    @data[:column_name].try(:to_s) || name
  end
  def filter
    @data[:filter]
  end
end
################################################################
class Columns
  extend Forwardable
  def_delegators :@columns, :map, :[], :select, :each, :keys, :first, :last
  
  attr_reader :names
  def initialize(columns = [])
    @columns = columns.map {|column| Column.new(column) }
  end
  def names
    @columns.map {|c| c.name}
  end
  def find_by_name(name)
    @columns.select {|c| c.name == name }.first
  end
end
