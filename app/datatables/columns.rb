class Columns
  extend Forwardable
  def_delegators :@columns, :map, :[], :select
  
  attr_reader :names
  def initialize(columns = [])
    @columns = columns.map do |column|
      case column
      when Symbol, String
        {
          name: column.to_s,
          column_name: column.to_s
        }
      when Hash
        column.symbolize_keys.transform_values {|v| v.to_s}
      end.tap do |col|
        col[:column_name] ||= column[:name]
        col
      end
    end
  end
  def names
    @columns.map {|c| c[:name]}
  end

end
