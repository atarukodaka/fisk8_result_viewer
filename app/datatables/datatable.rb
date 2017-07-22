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
  include Datatable::DeferLoadable
  include Datatable::Serversidable
  include Datatable::Decoratable
  
  def_delegators :@view_context, :params

  properties :columns, :hidden_columns, :default_orders, default: []
  properties :options, default: {}
  property(:settings){ default_settings }
  property(:records) {  fetch_records() }
  property(:searchable_columns){ columns }
  property(:orderable_columns) { columns }
  property :data, nil

  property(:sources) {
    # on default, sources for each columns have "table_name.column_name"
    # note that records required to get table_name
    table_name = records.table_name
    columns.map {|column|
      [column, [table_name, column].join('.')]
    }.to_h.with_indifferent_access
  }

  def initialize(view_context = nil)
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
    # order
    #default_sort(r)
    r
  end
  ################
  ## settings, etc
  def default_settings
    {
      processing: true,
      paging: true,
      pageLength: 25,
      #deferLoading: data.count,
    }
  end
  def ajax(serverside: false, url: )
    settings.update(serverSide: serverside, ajax: {url: url})
    self
  end
  def column_names
    columns.map(&:to_s)
  end
  def column_def(column_name)
    @column_defs ||= {}
    @column_defs[column_name] ||= Datatable::ColumnDef.new(column_name, self)
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
  def searching_arel_table_node(column_name, sv)  # TODO: nesecary ??
    column_def = column_def(column_name)
    operator = params["#{column_def.table_column}_operator"].to_s.to_sym

    column_def.model.searching_arel_table_node(column_def.table_column, sv, operator: operator)
  end
  
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
