class IndexDatatable < Datatable
  #
  #
  #
  include Datatable::TableKeys

  property :filters, []
  
  def add_filters(*columns, operator: :eq)
    [*columns].flatten.each {|column| add_filter(column, operator: operator)}
    self
  end
  def add_filter(column, operator: :eq, &block)
    key = table_key(column.to_sym)
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
    filters.reduce(super(data)) do |col, hash|
      (v = params[hash[:column]].presence) ? hash[:proc].call(col, v) : col
    end
  end
end
