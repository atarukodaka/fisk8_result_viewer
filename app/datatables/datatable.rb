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

  extend Forwardable
  extend Property

  def_delegators :@view_context, :params

  properties :records, :columns, default: []
  properties :settings, :sources, default: {}
  property :hidden_columns, []
  
  #prepend Datatable::Manipulatable    # use pretend to override data()
  include Datatable::Decoratable
  
  def initialize(view_context = nil)
    @data = nil
    @records = nil
    @columns = nil
    @view_context = view_context
    #@columns = (only) ? only : data.column_names.map(&:to_sym)
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
  ################
  ## data fetching/manipulation
  def fetch_records
    @records || []
  end
  def data
    @manipulated_data ||= manipulate(fetch_records)
  end
  def manipulate(data)
    manipulators.reduce(data){|d, m| m.call(d)}
  end
  def manipulators
    @manipulators ||= []
  end
  def add_manipulator(f)
    manipulators << f
    self
  end

  def settings
    default_settings.merge(@settings || {})
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
  ################################################################
  ## for server-side ajax
  ## for search
  def search_sql
    return "" if params[:columns].blank?

    keys = []
    values = []
    params[:columns].each do |num, hash|
      column_name = hash[:data]
      sv = hash[:search][:value].presence || next

      #key = table_keys[column_name.to_sym] || column_name
      key = sources[column_name.to_sym] || column_name
      keys << "#{key} like ? "
      values << "%#{sv}%"
    end
    # return such as  ['name like ? and nation like ?', 'foo', 'bar']
    (keys.blank?) ? '' : [keys.join(' and '), *values]
  end
  ################
  ## for sorting
  def order_sql
    return "" if params[:order].blank?

    ary = []
    params[:order].each do |_, hash|   ## params doesnt have map()
      column_name = columns[hash[:column].to_i]
      #key = table_keys[column_name.to_sym] || column_name
      key = sources[column_name.to_sym] || column_name
      ary << [key, hash[:dir]].join(' ')
    end
    ary
  end
  ################
  ## for paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  ################
  ## json output
  def as_json(opts={})
    new_data = data.where(search_sql).order(order_sql).page(page).per(per)    
    {
      iTotalRecords: new_data.model.count,
      iTotalDisplayRecords: new_data.total_count,
#      data: data.decorate.as_json(only: column_names),
      data: new_data.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end

end
################################################################
