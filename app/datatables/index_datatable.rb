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
    key = column_def.source(column)
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
    ## filters
    new_data = filters.reduce(super(data)) do |col, hash|
      (v = params[hash[:column]].presence) ? hash[:proc].call(col, v) : col
    end

    ## offset
    (offset = params[:offset].presence) ? new_data.offset(offset) : new_data
  end
end
