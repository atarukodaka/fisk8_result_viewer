################################################################
class Datatable 
  #
  # class for datatable gem. refer 'app/views/application/_datatable.html.slim' as well.
  #
  # in view,
  #
  # = Datatable.new(self).records(User.all).columns([:name, :address]).render
  #
  # for server-side ajax,
  #
  # = Datatable.new(self).settings(serverSide: true, ajax: users_list_path).render
  #

  extend Forwardable
  extend Property

  def_delegators :@view_context, :params

  properties :columns, :hidden_columns, :default_orders, default: []
  properties :settings, default: nil
  property(:records) {  fetch_records() }
  property :numbering, nil
  property(:searchable_columns){ columns }

#  properties :sources, default: {}
  property(:sources) {
    table_name = records.table_name
    columns.map {|column|
      [column, [table_name, column].join('.')]
    }.to_h
  }
  
  include Datatable::Serverside
  include Datatable::Decoratable
  
  def initialize(view_context = nil)
    @data = nil
    @settings = default_settings
    @view_context = view_context
    yield(self) if block_given?
  end
  def column_defs
    @column_defs ||= Datatable::ColumnDefs.new(self)
  end
  ## data fetching/manipulation
  def fetch_records
    raise "implemtent in derived class or give records directory"
  end
  def data
    @data ||= manipulate(records)
  end
  def manipulate(r)
    r
  end
  ################
  ## settings, etc
  def default_settings
    {
      processing: true,
    }
  end
  def settings
    @settings ||= default_settings
  end
  def table_settings
    settings.merge(
                   columns: column_names.map {|name|
                     {
                       data: name,
                       visible: !(hidden_columns.include?(name.to_sym)),
#                       searchable: (searchable_columns.include?(name.to_sym)),
                     }},
                   order: default_orders.map {|column, dir|
                     [column_names.index(column.to_s), dir]
                   },
                   )
  end
  def column_names
    columns.map(&:to_s)
  end
  def render(partial: "datatable", locals: {})
    @view_context.render(partial: partial, locals: {table: self }.merge(locals))
  end
  def table_id
    "table_#{self.object_id}"
  end
end
################################################################
