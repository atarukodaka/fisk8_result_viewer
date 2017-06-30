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
      collection: collection.decorate, # collection.page(params[:page]).decorate,
      pagination: false,
    }
  end

  def format_csv(collection, max_output: 1000)
    @filename = "#{controller_name}.csv"
    render cvs: :index, handlers: :csvbuilder, locals: { collection: collection.limit(max_output)}
  end
=begin
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
=end
  def index
    max_output = 1000
    #collection = sort(filter(create_collection))
    collection = filter(create_collection)
    
    respond_to do |format|
      format.html { format_html(collection) }
      format.json { format_json(collection, max_output: max_output) }
      format.csv { format_csv(collection, max_output: max_output) }
    end
  end
  ################################################################
  # json ajax
  def _columns
    [{name: "name"}, {competition_name: "competitions.name"}, {category: "category"},
     {segment: "segment"}, {season: "season"}, {date: "date"}, {result_pdf: "result_pdf"},
     {ranking: "ranking"}, {skater_name: "skaters.name"}, {nation: "skaters.nation"},
     {tss: "tss"}, {tes: "tes"}, {pcs: "pcs"}, {deductions: "deductions"}, {base_value: "base_value"}]
  end

  def search(collection)
    collection
  end
  def format_json(collection, max_output: 1000)
    col = search(collection)
    col = col.order("#{sort_column} #{sort_direction}").page(page).per(per).decorate
    #render :index, handlers: :jbuilder, locals: {collection: col}
    render json: {
      iTotalRecords: collection.model.count,
      iTotalDisplayRecords: col.total_count,
      data: col.map {|d| columns.keys.map {|k| [k, d.send(k)]}.to_h },
    }
  end
  def sort_column
    #collection.decorate.column_names[params[:iSortCol_0].to_i]
    #columns[params[:iSortCol_0].to_i].values.first
    columns.values[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  ## for paging
  def page
    params["iDisplayStart"].to_i / per + 1
  end
  def per
    params["iDisplayLength"].to_i > 0 ? params["iDisplayLength"].to_i : 10
  end
  
end
