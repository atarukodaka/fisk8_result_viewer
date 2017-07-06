class Datatable
  attr_accessor :collection, :columns, :order, :columns

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(collection, columns, order: nil)
    @collection = collection
    @order = order
    @columns = (columns.is_a? Array) ? Columns.new(columns) : columns
  end

  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end

  def column_names
    columns.names
  end
  def table_id
    "table_#{self.object_id}"
  end
  def as_json(opts={})
    collection.map do |item|
      column_names.map {|c| [c, item.send(c)]}.to_h
    end
  end
end

################################################################
