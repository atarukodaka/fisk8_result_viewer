class ListTable
  attr_reader :params, :columns, :filters
  
  def initialize(params, initial_collection, columns = {}, filters = {})
    @params = params
    @columns = columns
    @filters = filters
    @initial_collection = initial_collection
    @collection = nil
  end
  def collection
    @collection ||= filter(@initial_collection).limit(1000)
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
