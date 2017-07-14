class Datatable < Listtable
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
  #attr_accessor :rows, :columns, :settings, :order, :manipulator
  attr_accessor :collection, :settings, :order, :manipulator

  #def initialize(rows, columns, settings: {}) # , manipulators: [])
  def initialize(collection, only: nil, settings: {})
    #@columns = (columns.class == Array) ? Columns.new(columns) : columns
    #@columns = columns || []
    #@rows = rows
    @settings = settings
    @order ||= []
    super(collection, only: only)
    yield(self) if block_given?  # TODO: in Listtable?
  end
  def collection
    manipulate(@collection)
  end
  def decorate
    set_manipulator(->(r){ r.decorate } )
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
    data.limit(1000).as_json(only: columns)
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
      data.limit(1000).each do |row|
        csv << column_names.map {|k| row.send(k)}
      end
    end
  end
end
################################################################
