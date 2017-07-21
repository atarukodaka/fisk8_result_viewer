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
  property(:settings){ default_settings }
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
  
  include Datatable::Decoratable
  
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
    if default_orders.present?
      r.order(default_orders.map {|column, dir| [sources[column], dir].join(' ')})
    else
      r
    end
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
  ################################################################
  ## for server-side ajax
  ## searching
  def searching_arel_table_node(column_name, sv)
    table_name, table_column = sources[column_name].split(/\./)
    model = table_name.classify.constantize
    arel_table = model.arel_table[table_column]
    operator = params["#{table_column}_operator"].to_s.to_sym

    case operator
      when :eq, :lt, :lteq, :gt, :gteq
      arel_table.send(operator, sv)
    else
      arel_table.matches("%#{sv}%")
    end
  end
  def search_sql
    return "" if params[:columns].blank?

    params.require(:columns).values.map {|item|
      sv = item[:search][:value].presence || next
      column_name = item[:data]
      #next unless column_defs.searchable(column_name)

      searching_arel_table_node(column_name, sv)
    }.compact.reduce(&:and)
  end
  ################
  ## sorting
  def order_sql
    return "" if params[:order].blank?

    params.require(:order).values.map do |hash|
      column_name = columns[hash[:column].to_i]
      #key = column_defs.source(column_name)
      key = sources[column_name.to_sym]
      [key, hash[:dir]].join(' ')
    end
  end
  ################
  ## paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  ################
  ## json output
  def as_json(opts={})
    @data = data.where(search_sql).order(order_sql).page(page).per(per)    
    {
      iTotalRecords: records.count,
      iTotalDisplayRecords: data.total_count,
      data: expand_data(data.decorate)
    }
  end

end
################################################################
