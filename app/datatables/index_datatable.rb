class IndexDatatable < Datatable
  #
  #
  #
  include Datatable::Params
  include Datatable::TableKeys

  attr_reader :filters
  
  def initialize(*args)
    super(*args)
    @filters ||= {}
    @order ||= []
  end

  def add_filter(column, operator: :eq, &block)
    key = table_keys(column)
    if block_given?
      @filters[column] = block
    else
      @filters[column] =
        case operator
        when :eq
          ->(v){ where(key => v) }
        when :matches
          ->(v){ where("#{key} like ?", "%#{v}%") }
        else
          raise
        end
    end
  end
  def manipulate(collection)
    filters.reduce(super(collection)) do |col, ary|
      key, filter = ary
      (v = params[key].presence) ? col.instance_exec(v, &filter) : col
    end
  end

  protected
  ## for elements/components controllers
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
  end

end
