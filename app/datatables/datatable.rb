class Datatable
  attr_accessor :collection, :columns, :order, :columns, :params

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
    @manipulated_collection = nil
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

  def collection
    @manipulated_collection ||= manipulate_collection(@init_collection)
  end
  def manipulate_collection(col)
    execute_filters(col)
  end
  def execute_filters(col)
    columns.each do |column|
      if (sv = params[column[:name]].presence)
        col =
          if (filter = column[:filter] )
            filter.call(col, sv)
          else
            col.where("#{column[:by]} like ? ", "%#{sv}%")
          end
      end
    end
    col
  end
  def as_json(opts={})
    collection.map do |item|
      column_names.map {|c| [c, item.send(c)]}.to_h
    end
  end
end

