class Datatable
  attr_accessor :collection, :columns, :filters, :params, :order, :columns

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  #def initialize(initial_collection, columns, filters: {}, params: {}, order: nil)
  def initialize(initial_collection, columns, manipulator: nil, order: nil)
    @initial_collection = initial_collection
    @filters = filters
    @params = params
    @order = order
    @manipulator = manipulator
    @columns = (columns.is_a? Array) ? Columns.new(columns) : columns
  end

  def execute_filters(col)
    # input params
    filters.each do |key, pr|
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end

  def render(view, partial: "datatable", locals: {})
    datatable_options = {
      bProcessing: true,
      bFilter: true,
    }
    view.render partial: partial, locals: {table: self, options: datatable_options }.merge(locals)
  end

  def fetch_collection
    #execute_filters(@initial_collection)
    if @manipulator
      @manipulator.manipulate(@initial_collection)
    else
      @initial_collection
    end
  end
  def column_names
    #@columns.map {|c| c[:name]}
    columns.names
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
