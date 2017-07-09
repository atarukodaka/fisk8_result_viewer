
class Datatable
  attr_accessor :order, :columns, :settings, :rows
  def initialize(columns: [], rows: [], settings: {})
    @columns = Columns.new(columns)
    @rows = rows
    @settings = settings
  end
   
  def column_names
    @columns.map {|c| c[:name] }
  end

  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end
  def table_id
    "table_#{self.object_id}"
  end
  def table_settings
    {
      processing: true,
      filter: true,
      columns: column_names.map {|name| {data: name}},
      order: (order) ? order.map {|name, dir| [column_names.index(name.to_s), dir.to_s]} : [],
    }.merge(settings)
  end
  def as_json(opts={})
    rows.map do |item|
      column_names.map do |col_name|
        [col_name,
         (item.class == Hash) ? item[col_name.to_sym] : item.send(col_name)
        ]
      end.to_h
    end
  end
end

class ServersideDatatable < Datatable
  attr_reader :params
  def initialize(columns:, rows: nil, params: params)
    super(columns: columns, rows: rows)
    @params = params
  end
  def fetch_rows
    @rows
  end
  def rows
    @manipulated_row ||= @rows.where(filter_sql).order(order_sql).page(page).per(per)
  end

  def filter_sql
    return "" if params[:columns].blank?

    keys = []
    values = []
    params[:columns].each do |num, hash|
      column_name = hash[:data]
      sv = hash[:search][:value].presence || next
      column = columns.find_by_name(column_name) || raise
      keys << "#{column.key} like ? "
      values << "%#{sv}%"
    end
    if keys.blank?
      ""
    else
      [keys.join(' and '), *values]
    end
  end
  ## for sorting
  def order_sql
    return "" if params[:order].blank?

    ary = []
    params[:order].each do |_, hash|  # TODO: each for columns
      column = columns[hash[:column].to_i]
      ary << [column.key, hash[:dir]].join(' ')
    end
    ary
  end
  ## for paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  def as_json(opts={})
    {
      iTotalRecords: rows.count,
      iTotalDisplayRecords: rows.total_count,
      data: rows.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end
end

