class Datatable
  attr_accessor :collection, :order, :columns, :params, :column, :ajax

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(collection, columns, params: {}, order: nil, ajax: nil)
    @init_collection = collection
    @order = order
    @params = params
    @columns = Columns.new(columns)
    @ajax = ajax
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
  def table_settings
    {
      processing: true,
      filter: true,
      paging: true,     # option
      page_length: 25,   # opton
      columns: columns.map {|c| {data: c[:name]}},  # TODO 
      order: (order) ? order.map {|name, dir| [column_names.index(name.to_s), dir.to_s]} : [],
      serverSide: !!ajax,
      ajax: (ajax) ? ajax : "",
    }
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

