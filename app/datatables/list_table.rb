class ListTable
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

  def collection
    @collection ||= fetch_collection
  end
  def fetch_collection
    @initial_collection
  end
end

=begin
class LListTable
  attr_reader :params, :columns, :filters
  
  def initialize(params, initial_collection, columns = {}, filters = {})
    @params = params
    @columns =
      case columns
      when Array
        columns.map {|d| [d, d]}.to_h
      else
        columns
      end
    @filters = filters
    @initial_collection = initial_collection
    @collection = nil
  end
  def collection
    @collection ||= filter(@initial_collection)   #.try(:limit, 1000)
  end
  def as_json(options={})
    collection.map {|d| columns.keys.map {|k| [k, d.send(k)]}.to_h }
  end
  def to_csv
    CSV.generate(headers: columns.keys, write_headers: true, force_quotes: true) do |csv|
      collection.each do |row|
        csv << columns.keys.map {|k| row.send(k)}
      end
    end
  end
  def filter(col)
    filters.each do |key, pr|
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
end
=end
