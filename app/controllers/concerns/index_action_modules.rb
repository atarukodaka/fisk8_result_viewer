module IndexActionModules
  # for elements/components search
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    arel = model_klass.arel_table[key].send(operator, value.to_f)
  end

  def filters
    {}
  end
  def filter(col)
    filters.each do |key, pr|
      col = pr.call(col, params[key]) if params[key].present? && pr
    end
    col
  end

  def decorator
    begin
      "#{controller_name.singularize.camelize}Decorator".constantize
    rescue NameError
      nil
    end
  end

  def colleciton
    []
  end
  def format_html
    pagination = true
    col = (pagination) ? collection.page(params[:page]) : collection
    
    locals = {
      collection: col.decorate,
      pagination: pagination,
    }
    render locals: locals
  end

  def format_json
    max_output = 1000
    render :index, handlers: :jbuilder, locals: {collection: collection.limit(max_output)}
  end
  def format_csv
    max_output = 1000
    col = collection.limit(max_output)
    headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
    
    render cvs: "index.csv.ruby", locals: { collection: col, }
  end
  
  def index
    respond_to do |format|
      format.html { format_html }
      format.json { format_json }
      format.csv { format_csv }
    end
  end
end
