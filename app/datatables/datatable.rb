###############################################################
class Datatable
  #
  # class for datatable gem. refer 'app/views/application/_datatable.html.slim' as well.
  #
  # in view,
  # = Datatable.new(self).records(User.all).columns([:name, :address]).render
  #
  # for server-side ajax,
  # = Datatable.new(self).ajax(serverside: true, url: users_list_path).render

  extend Forwardable
  extend Property
  include Datatable::DeferLoadable
  include Datatable::Serversidable
  include Datatable::Decoratable
  include Datatable::Limitable
  
  def_delegators :@view_context, :params

  property :data, nil
  property(:records) {  fetch_records() }
  properties :columns, :default_orders, default: []
  property(:settings){ default_settings }
  property(:column_defs) { ColumnDefs.new(columns, table_name: records.table_name) }
  properties :options, default: {}
  
  def initialize(view_context = nil)
    @view_context = view_context
    yield(self) if block_given?
  end
  def searchable_columns
    column_defs.values.select(&:searchable).map(&:name)
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
      paging: true,
      pageLength: 25,
    }
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
  def order
    default_orders.map {|column, dir|
      [column_names.index(column.to_s), dir]
    }
  end
  ##
  ################
  ## format
  def as_json(*args)
    data.map do |item|
      column_names.map do |column_name|
        [column_name, item.try(:send,column_name.to_sym) || item[column_name.to_sym]]
      end.to_h.as_json(*args)
    end
  end
end

## -- end of datatable.rb
