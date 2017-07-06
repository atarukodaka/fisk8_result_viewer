class Datatable
  attr_accessor :collection, :columns, :filters, :params, :order

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(initial_collection, columns, filters: {}, params: {}, order: nil)
    @initial_collection = initial_collection
    @filters = filters
    @params = params
    @order = order
    @columns = columns.map do |column|
      case column
      when Symbol, String
        {
          name: column.to_s,
          table: initial_collection.table_name,
          column_name: column.to_s
        }
      when Hash
        column.symbolize_keys.transform_values {|v| v.to_s}
      end.tap do |col|
        col[:column_name] ||= column[:name]
        col[:table] ||= initial_collection.table_name
      end
    end
  end

  def render(view, partial: "datatable", locals: {})
    datatable_options = {
      bProcessing: true,
      bFilter: true,
    }
    view.render partial: partial, locals: {table: self, options: datatable_options }.merge(locals)
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
  def as_json(opts={})
    collection.map do |item|
      column_names.map {|c| [c, item.send(c)]}.to_h
    end
  end
end

################################################################
