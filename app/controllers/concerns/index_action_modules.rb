module IndexActionModules
  def score_filters
    @_filters ||= IndexFilters.new.tap {|f|
      f.filters = {
        skater_name: {operator: :like, input: :text_field, model: Score},
        category: {operator: :eq, input: :select, model: Score},      
        segment: {operator: :eq, input: :select, model: Score},      
        nation: {operator: :eq, input: :select, model: Score},      
        competition_name: {operator: :eq, input: :select, model: Score},
        isu_championships: { operator: :eq, input: :checkbox, model: Competition, value: true, label: "ISU Championships Only"},        
        season: { operator: :eq, input: :select, model: Competition},
      }
    }
  end

  def filters
    score_filters
  end
  def display_keys
    []
  end

  def decorator
    begin
      "#{controller_name.camelize}ListDecorator".constantize
    rescue NameError
      nil
    end
  end
  def colleciton
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
