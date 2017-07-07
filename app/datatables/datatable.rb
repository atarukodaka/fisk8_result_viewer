class Datatable
  attr_accessor :collection, :columns, :order, :columns, :params

  def self.create(*args)
    self.new(*args).tap do |table|
      yield(table) if block_given?
    end
  end

  def initialize(collection, columns, params: {}, order: nil)
    @init_collection = collection
    @order = order
    @params = params
    @columns = (columns.is_a? Array) ? Columns.new(columns) : columns
    @manipulated_collection = nil
  end

  def render(view, partial: "datatable", locals: {})
    view.render partial: partial, locals: {table: self }.merge(locals)
  end

  def column_names
    columns.names
  end
  def table_id
    "table_#{self.object_id}"
  end

  def collection
    @manipulated_collection ||= manipulate_collection(@init_collection)
  end
  def as_json(opts={})
    collection.map do |item|
      column_names.map {|c| [c, item.send(c)]}.to_h
    end
  end
  ################################################################
  def manipulate_collection(col)
    execute_filters(col).order(order_sql).page(page).per(per)
  end

  def execute_filters(col)
=begin
    ## filter params
    filters.each do |key, pr|
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
=end
    columns.each do |column|
      if (sv = params[column[:name]].presence)
        if column[:filter]
          col = column[:filter].call(col, sv) 
        else
          table = column[:table] || col.table_name
          #col = col.where("#{table}.#{column[:column_name]} like ? ", "%#{sv}%")
          #col = col.where("#{table}.#{column[:column_name]}" => sv)
          col = col.where(column[:by] => sv)
        end
      end
    end
    return col if params[:columns].blank?

    
    # TODO: checkinjection
    params[:columns].each do |num, hash|
      column_name = hash[:data]  # TODO
      search_value = hash[:search][:value]  # .presence ||  params[column_name]
      if search_value.present?
        column = columns.select {|h| h[:name] == column_name}.first || raise
        #table = column[:table] || col.table_name
        #col = col.where("#{table}.#{column[:column_name]} like ?", "%#{search_value}%")
        col = col.where("#{column[:by]} like ?", "%#{search_value}%")
      end
    end
    col
  end
  
  ## for paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  ## for sorting
  def order_sql
    return "" if params[:order].blank?
     params[:order].permit!.to_h.map do |_, hash|
      column = columns[hash[:column].to_i]
      #key = (column[:table]) ? [column[:table], column[:column_name]].join(".") : column[:column_name]
      [column[:by], hash[:dir]].join(' ')
    end
  end
  
end

################################################################
