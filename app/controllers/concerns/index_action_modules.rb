module IndexActionModules
  def filters
    {}
  end
  def filter(col)
    filters.each do |key, pr|
      col = pr.call(col, params[key]) if params[key].present? && pr
    end
    col
  end
  def colleciton
    controller_name.singuralize.constantize.send(:all)
  end
  def format_html
    pagination = true
    col = (pagination) ? collection.page(params[:page]) : collection
    
    render locals: {
      collection: col.decorate,
      pagination: pagination,
    }
  end

  def format_json
    render :index, handlers: :jbuilder, locals: {collection: collection.limit(@max_output)}
  end

  def format_csv
    col = collection.limit(@max_output)
    @filename = "#{controller_name}.csv"
    render cvs: :index, handlers: :csvbuilder, locals: { collection: col, }
  end
  
  def index
    @max_output = 1000
    respond_to do |format|
      format.html { format_html }
      format.json { format_json }
      format.csv { format_csv }
    end
  end
end
