class Datatable 
  #
  # class for datatable gem. refer 'app/views/application/_datatable.html.slim' as well.
  #
  # in view,
  #
  # = Datatable.new(User.all).render(self)
  #
  # for server-side ajax,
  #
  # = Datatable.new(User.all, settings: { server-side: true, ajax: users_list_path})
  #
  #attr_accessor :rows, :columns, :settings, :order, :manipulator
  attr_accessor :columns, :data, :settings

  prepend Datatable::Manipulatable    # use pretend to override data()
  include Datatable::Decoratable
  
  def initialize(data, only: nil, settings: {})   ## TODO: except
    @data = data
    @columns = (only) ? only : data.column_names
    @settings = default_settings.merge(settings)
    yield(self) if block_given?
  end
  def column_names
    @columns.map(&:to_s)
  end
  def render(view, partial: "datatable", locals: {}, settings: {})
    self.settings.update(settings)
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  def table_id
    "table_#{self.object_id}"
  end
  # settings
  def default_settings
    {
      processing: true,
      filter: true,
      order: [],
      columns: column_names.map {|name| {data: name}},
    }
  end
  def table_settings
    default_settings.merge(@settings)    
  end
  def add_settings(hash)
    hash.each do |key, value|
      settings[key] = value
    end
    self
  end
  ################
  ## output format
  def limitted_data
    data.limit(1000)
  end
  def as_json(opts={})
    #imitted_data.as_json(only: columns)
    limitted_data.map do |item|
      column_names.map do |column|
        item.send(column)
      end
    end
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
