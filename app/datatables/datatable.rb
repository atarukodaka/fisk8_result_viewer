
class Datatable
  attr_accessor :order, :columns, :settings, :rows
  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end
  def initialize(rows, columns, settings: {})
    @columns = (columns.class == Array) ? Columns.new(columns) : columns
    @rows = rows
    @settings = settings
  end
   
  def column_names
    @columns.map {|c| c.name }
  end

  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  def table_id
    "table_#{self.object_id}"
  end
  def table_settings
    {
      processing: true,
      filter: true,
      columns: column_names.map {|name| {data: name}},
      order: (order) ? order.map {|name, dir| [column_names.index(name.to_s), dir.to_s]} : [],
    }.merge(settings)
  end
  def as_json(opts={})
    rows.map do |item|
      column_names.map do |col_name|
        [col_name,
         (item.class == Hash) ? item[col_name.to_sym] : item.send(col_name)
        ]
      end.to_h
    end
  end
end

