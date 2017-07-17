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
  # = Datatable.new(User.all).update_settings(server-side: true, ajax: users_list_path).render(self)
  #

  extend Property

  properties :columns, :data
  properties :params, :settings, :table_keys, default: {}
  property :hidden_columns, []
  
  prepend Datatable::Manipulatable    # use pretend to override data()
  include Datatable::Decoratable
  
  def initialize(data, only: nil)   ## TODO: except
    @data = data
    @columns = (only) ? only : data.column_names.map(&:to_sym)
    yield(self) if block_given?
  end
  def default_settings
    {
      processing: true,
      filter: true,
      order: [],
      columns: column_names.map {|name| {
          data: name,
          visible: (hidden_columns.include?(name.to_sym)) ? false : true,
#          className: name.underscore.downcase
          
        }},
    }
  end
  def settings
    default_settings.merge(@settings)
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
    data.limit(10000)
  end
  def as_json(opts={})
    #imitted_data.as_json(only: columns)
    limitted_data.map do |item|
      column_names.map do |column|
        [column, item.send(column)]
      end.to_h
    end
  end
  def to_csv(opt={})
    require 'csv'
    CSV.generate(headers: column_names, write_headers: true) do |csv|
      limitted_data.each do |row|
        csv << column_names.map {|k| row.send(k)}
      end
    end
  end
end
################################################################
