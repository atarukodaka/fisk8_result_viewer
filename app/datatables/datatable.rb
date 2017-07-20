###############################################################
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
  property :data, nil

  property(:sources) {
    # on default, sources for each columns have "table_name.column_name"
    # note that records required to get table_name
    table_name = records.table_name
    columns.map {|column|
      [column, [table_name, column].join('.')]
    }.to_h.with_indifferent_access
  }
  
  include Datatable::Serverside
  include Datatable::Decoratable
  
  def initialize(view_context = nil)
    @settings = default_settings.with_indifferent_access
    @view_context = view_context
    yield(self) if block_given?
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
  def expand_data(d=nil)
    (d || data).map do |item|
      column_names.map do |column_name|
        [column_name, item.try(:send,column_name.to_sym) || item[column_name.to_sym]]
      end.to_h
    end
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
                       searchable: (searchable_columns.include?(name.to_sym)),
                     }},
                   order: default_orders.map {|column, dir|
                     [column_names.index(column.to_s), dir]
                   },
                   )
  end
  def ajax(serverside: false, url: )
    settings.update(serverSide: serverside, ajax: {url: url})
    self
  end
  def column_names
    columns.map(&:to_s)
  end
  def render(partial: "datatable", locals: {})
    @view_context.render(partial: partial, locals: { datatable: self }.merge(locals))
  end
  def table_id
    "table_#{self.object_id}"
  end
  def row(r)
  end
end
################################################################
