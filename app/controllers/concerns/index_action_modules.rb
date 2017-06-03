module IndexActionModules
  def score_filters
    {
      skater_name: ->(col, v){ col.where("scores.skater_name like ? ", "%#{v}%")},
      category: ->(col, v)   { col.where("scores.category" => v) },
      segment: ->(col, v)    { col.where("scores.segment" => v) },
      nation: ->(col, v)     { col.where("scores.nation" => v) },
      competition_name: ->(col, v)     { col.where("scores.competition_name" => v) },
      isu_championships_only:->(col, v){ col.where("competitions.isu_championships" => v =~ /true/i) },
      season: ->(col, v){ col.where("competitions.season" => v) },
    }
=begin    
    @_filters ||= IndexFilters.new.tap {|f|
      f.filters = {
        skater_name: {operator: :like, input: :text_field, model: Score},
        category: {operator: :eq, input: :select, model: Score, },
        segment: {operator: :eq, input: :select, model: Score,},
        nation: {operator: :eq, input: :select, model: Score},      
        competition_name: {operator: :eq, input: :select, model: Score},
        isu_championships: { operator: :eq, input: :checkbox, model: Competition, value: true, label: "ISU Championships Only"},
        season: { operator: :eq, input: :select, model: Competition},
      }
    }
=end
  end

  # for elements/components search
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    arel = model_klass.arel_table[key].send(operator, value.to_f)
  end

  def filters
    score_filters
  end
  def filter(col)
    filters.each do |key, pr|
      col = pr.call(col, params[key]) if params[key].present? && pr
    end
    col
  end

  def display_keys
    []
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
    col = collection.page(params[:page]) if pagination
    
    locals = {
      collection: (decorator) ? decorator.decorate_collection(col) : col,
      filters: filters,
      display_keys: display_keys,
      pagination: pagination,
    }
    render locals: locals
  end

  def format_json
    max_output = 1000
    render json: collection.limit(max_output).select(display_keys) 
  end
  def format_csv
    max_output = 1000
    col = collection.limit(max_output) #.select(display_keys)
    headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
    
    render cvs: "index.csv.ruby", locals: { collection: col, display_keys: display_keys }
  end
  
  def index
    respond_to do |format|
      format.html { format_html }
      format.json { format_json }
      format.csv { format_csv }
    end
  end
end
