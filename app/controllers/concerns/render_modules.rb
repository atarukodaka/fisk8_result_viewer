module RenderModules
  def render_index_as_formats(collection, display_keys: [], filters: {}, max_output: 1000, decorator: nil, pagination: true)
    respond_to do |format|
      format.html {
        collection = collection.page(params[:page]) if pagination
        @collection = (decorator) ? decorator.decorate_collection(collection) : collection
        @filters = filters
        @display_keys = display_keys
        @pagination = pagination
      }
      format.json { render json: collection.limit(max_output).select(display_keys) }
      format.csv {
        @collection = collection.limit(max_output)
        headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
      }
    end
  end
  
=begin
  def render_formats(collection, max_output: 1000, decrator_klass: nil)
    collection = collection.offset(params[:offset].to_i) if params[:offset]
    respond_to do |format|
      format.html { } # @collection = collection.page(page); render }
      format.json { render json: collection.limit(max_output) }
      format.csv {
        @collection = collection.limit(max_output)
        headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
        #render template: csv_template if csv_template
      }
    end
  end
=end
end
