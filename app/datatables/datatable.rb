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
  # = Datatable.new(self).update_settings(server-side: true, ajax: users_list_path).render
  #

  extend Forwardable
  extend Property

  def_delegators :@view_context, :params

  properties :records, :columns, :hidden_columns, default: []
  properties :sources, default: {}
  properties :settings

  include Datatable::Decoratable
  
  def initialize(view_context = nil)
    @data = nil
    @settings = default_settings
    @view_context = view_context
    yield(self) if block_given?
  end
  def column_def
    @column_def ||= Datatable::ColumnDef.new(self)
  end
  def default_settings
    {
      processing: true,
      filter: true,
      order: [],
      columns: column_names.map {|name| {
          data: name,
          visible: (hidden_columns.include?(name.to_sym)) ? false : true,
        }},
    }
  end
  ################
  ## data fetching/manipulation
  def fetch_records
    @records || []
  end
  def data
    @data ||= manipulate(fetch_records)
  end
  def manipulate(r)
    r
  end
=begin
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
=end
  ################
  ## settings, etc
  def settings
    @settings ||= default_settings
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
  ## searching
  def search_sql
    return "" if params[:columns].blank?

    keys = []
    values = []
    params[:columns].each do |num, hash|
      column_name = hash[:data]
      sv = hash[:search][:value].presence || next

      key = column_def.source(column_name)
      keys << "#{key} like ? "
      values << "%#{sv}%"
    end
    # return such as  ['name like ? and nation like ?', 'foo', 'bar']
    (keys.blank?) ? '' : [keys.join(' and '), *values]
  end
  ################
  ## sorting
  def order_sql
    return "" if params[:order].blank?

    ary = []
    params[:order].each do |_, hash|   ## params doesnt have map()
      column_name = columns[hash[:column].to_i]
      key = column_def.source(column_name)
      ary << [key, hash[:dir]].join(' ')
    end
    ary
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
    new_data = data.where(search_sql).order(order_sql).page(page).per(per)    
    {
      iTotalRecords: new_data.model.count,
      iTotalDisplayRecords: new_data.total_count,
      data: new_data.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end

end
################################################################
