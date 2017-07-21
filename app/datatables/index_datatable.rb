class IndexDatatable < Datatable
  #
  #
  #
  property :filters, []

  ################
  ## filters
  def filter_keys
    filters.map {|d| d[:column].to_sym}
  end
  def add_filters(*columns, operator: :eq)
    [*columns].flatten.each {|column| add_filter(column, operator: operator)}
    self
  end
  def add_filter(column, operator: :eq, &block)
    #key = table_keys[column.to_sym] || column.to_s
    #key = sources[column.to_sym] || column.to_s
    #key = column_defs.source(column)
    key = sources[column]
    proc =
      if block_given?
        block
      else
        case operator
        when :eq
          ->(c, v){ c.where(key => v) }
        when :matches
          ->(c, v){ c.where("#{key} like ?", "%#{v}%") }
        else
          raise "no such operator: #{operator}"
        end
      end
    @filters ||= []
    @filters << { column: column, proc: proc}
    self
  end
  ################
  ## manipulator
  def manipulate(data)
    node = searchable_columns.map(&:to_s).map do |column_name|
      next unless sv = params[column_name].presence
      node = searching_arel_table_node(column_name, sv)
    end.compact.reduce(&:and)
    data = data.where(node)
  end
=begin  
  def __manipulate(data)
    ## filters
    new_data = filters.reduce(super(data)) do |col, hash|

      
      (v = params[hash[:column]].presence) ? hash[:proc].call(col, v) : col
    end

    ## offset
    (offset = params[:offset].presence) ? new_data.offset(offset) : new_data
  end
=end
  ################
  # columns
  def searchable_columns
    filter_keys
  end

end
