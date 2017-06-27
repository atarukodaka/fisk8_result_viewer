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
  def create_collection
    []
  end
  def format_html(collection)
    render locals: {
      collection: collection.page(params[:page]).decorate,
      pagination: true,
    }
  end

  def format_json(collection, max_output: 1000)
    render :index, handlers: :jbuilder, locals: {collection: collection.limit(max_output)}
  end

  def format_csv(collection, max_output: 1000)
    @filename = "#{controller_name}.csv"
    render cvs: :index, handlers: :csvbuilder, locals: { collection: collection.limit(max_output)}
  end
  
  def index
    max_output = 1000
    collection = filter(create_collection)
    respond_to do |format|
      format.html { format_html(collection) }
      format.json { format_json(collection, max_output: max_output) }
      format.csv { format_csv(collection, max_output: max_output) }
    end
  end
end
