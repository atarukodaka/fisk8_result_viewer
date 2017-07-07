class Datatable
  attr_accessor :collection, :order, :columns, :params, :column

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(collection, columns, params: {}, order: nil)
    @init_collection = collection
    @order = order
    @params = params
    @columns = Columns.new(columns)
    @collection = nil
  end
  ################
  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end

  def column_names
    columns.names
  end
  
  def table_id
    "table_#{self.object_id}"
  end

  def fetch_collection
    nil
  end
  def collection
    @collection ||= manipulate_collection(fetch_collection || @init_collection)
  end
  
  def manipulate_collection(col)
    col
  end
  
  def as_json(opts={})
    collection.map do |item|
      column_names.map {|c| [c, item.send(c)]}.to_h
    end
  end
end

