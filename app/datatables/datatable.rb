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

  #attr_accessor :columns, :data, :settings
  extend Property

  properties :columns, :data, :settings
  prepend Datatable::Manipulatable    # use pretend to override data()
  include Datatable::Decoratable
  
  #def initialize(data, only: nil, settings: {})   ## TODO: except
  def initialize(data, only: nil)   ## TODO: except
    @data = data
    @columns = (only) ? only : data.column_names.map(&:to_sym)
    #@settings = default_settings

    @settings = {
      processing: true,
      filter: true,
      order: [],
      columns: column_names.map {|name| {data: name}},
    }
    yield(self) if block_given?
  end
  def column_names
    @columns.map(&:to_s)
  end
  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  def table_id
    "table_#{self.object_id}"
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
