class Datatable
  attr_accessor :collection, :order, :params, :ajax

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(params: {})
    @params = params
    @columns = [] # Columns.new(create_columns())
    @collection = nil
  end
  ################
  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end

  def columns=(col)
    @columns = (col.is_a? Array) ? Columns.new(col) : col
  end

  def columns
    @columns
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
      columns: columns.map {|c| {data: c[:name]}},
      order: (order) ? order.map {|name, dir| [column_names.index(name.to_s), dir.to_s]} : [],
      serverSide: !!ajax,
      ajax: (ajax) ? ajax : "",
    }
  end
  def fetch_collection
    nil
  end
  def collection
    @collection ||= manipulate_collection(fetch_collection)
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

