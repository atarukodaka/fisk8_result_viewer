using ToDirection

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
    raise "should be implemented in derived class"
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
  def sort_keys
    {}
  end
  def default_sort_key
    #[:id, :desc]
    { key: :id, direction: :desc }
    
  end
  def sort(collection)
    if (sort = params[:sort]) && (sort_keys.keys.include?(sort.to_sym) || collection.column_names.include?(sort))
      direction = (sort == params[:sort]) ? params[:direction].to_direction.current : :asc
    end
    sort ||= default_sort_key[:key]
    direction ||= default_sort_key[:direction]
    sort_key_with_table = sort_keys[sort.to_sym] || [collection.table.name, sort].join('.')
    params[:direction] = direction
    collection = collection.order([sort_key_with_table, direction].join(' '))
  end
  def index
    max_output = 1000
    collection = sort(filter(create_collection))
    
    respond_to do |format|
      format.html { format_html(collection) }
      format.json { format_json(collection, max_output: max_output) }
      format.csv { format_csv(collection, max_output: max_output) }
    end
  end
end
