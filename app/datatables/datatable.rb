class Datatable
  #
  # class for datatable gem. refer 'app/views/application/_datatable.html.slim' as well.
  #
  # in view,
  #
  # = Datatable.new(User.all, [:name, :address]).render(self)
  #
  # for server-side ajax,
  #
  # = Datatable.new(User.all, [:name, :address], settings: { server-side: true,
  #       ajax: users_list_path})
  #
  attr_accessor :rows, :columns, :settings, :order, :manipulator

  def initialize(rows, columns, settings: {}) # , manipulators: [])
    @columns = (columns.class == Array) ? Columns.new(columns) : columns
    @rows = rows
    @settings = settings
    @order ||= []
    yield(self) if block_given?
  end
  def rows
    @manipulated_rows ||= manipulate_rows(@rows)
  end
=begin
  def manipulate_rows(r)
    r = (manipulator) ? manipulator.call(r) : r
  end
=end
  def manipulate_rows(r)
    r
  end
  def column_names
    @columns.map {|c| c.name }
  end

  def render(view, partial: "datatable", locals: {}, settings: {})
    self.settings.update(settings)
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  def table_id
    "table_#{self.object_id}"
  end
  # settings
  def table_settings
    {
      processing: true,
      filter: true,
      columns: column_names.map {|name| {data: name}},
      order: order.map {|name, dir|
        [column_names.index(name.to_s), dir.to_s]
      },
    }.merge(settings)
  end
  def add_settings(hash)
    hash.each do |key, value|
      settings[key] = value
    end
    self
  end
  ################
  ## output format
  def as_json(opts={})
    rows.limit(1000).as_json(only: column_names)
=begin
    rows.limit(1000).map do |item|
      column_names.map do |col_name|
        [col_name,
         (item.class == Hash) ? item[col_name.to_sym] : item.send(col_name)
        ]
      end.to_h
    end
=end
  end
  def to_csv(opt={})
    require 'csv'
    CSV.generate(headers: column_names, write_headers: true) do |csv|
      rows.limit(1000).each do |row|
        csv << column_names.map {|k| row.send(k)}
      end
    end
  end
end
################################################################
