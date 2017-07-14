class IndexDatatable < Datatable
  #
  #
  # 
  include Datatable::Params
  
  def manipulate_rows(rws)
    # call columns.filter if exists
    columns.each do |column|
      filter = column.filter || next
      sv = params[column.name].presence || next
      rws = filter.call(rws, sv)
    end
    rws
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
