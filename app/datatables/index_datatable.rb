class IndexDatatable < Datatable
  #
  #
  #
  #include Datatable::TableKeys

  property :filters, []

  def filter_keys
    filters.map {|d| d[:column].to_sym}
  end
  def add_filters(*columns, operator: :eq)
    [*columns].flatten.each {|column| add_filter(column, operator: operator)}
    self
  end
  def add_filter(column, operator: :eq, &block)
    #key = table_keys[column.to_sym] || column.to_s
    key = sources[column.to_sym] || column.to_s
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
  def manipulate(data)
    ## filters
    new_data = filters.reduce(super(data)) do |col, hash|
      (v = params[hash[:column]].presence) ? hash[:proc].call(col, v) : col
    end

    ## offset
    (offset = params[:offset].presence) ? new_data.offset(offset) : new_data
  end
=begin
  ################
  ## output
  def limitted_data
    data.limit(10000)
  end

  def as_json(opts={})
    #imitted_data.as_json(only: columns)
    limitted_data.map do |item|
      column_names.map do |column|
        [column, item.send(column)]
      end.to_h
    end
  end
=end

=begin
  def to_csv(opt={})
    require 'csv'
    CSV.generate(headers: column_names, write_headers: true) do |csv|
      limitted_data.each do |row|
        csv << column_names.map {|k| row.send(k)}
      end
    end
  end
=end
end
