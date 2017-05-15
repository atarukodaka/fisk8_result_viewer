module RenderModules
  def render_formats(collection, page: 1, max_output: 1000)
    collection = collection.offset(params[:offset].to_i) if params[:offset]
    respond_to do |format|
      format.html { @collection = collection.page(page); render }
      format.json { render json: collection.limit(max_output) }
      format.csv {
        @collection = collection.limit(max_output)
        headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
        #render template: csv_template if csv_template
      }
    end
  end
end
