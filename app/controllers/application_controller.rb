class ApplicationController < ActionController::Base
  #include RenderModules

  def score_filters
    {
      skater_name: {operator: :like, input: :text_field, model: Score},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},
      season: { operator: :eq, input: :select, model: Competition},
    }
  end

  def filters
    {}
  end
  def display_keys
    []
  end

  def set_filter_keys
    decorator.set_filter_keys(filters.keys)
  end

  def decorator
    "#{controller_name.camelize}ListDecorator".constantize
  end

  def index
    set_filter_keys
    
    render_index_as_formats(collection, filters: filters, display_keys: display_keys, decorator: decorator)
  end

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

  ################################################################
  protect_from_forgery with: :exception

  unless Rails.env.development?
  #if Rails.env.production?
    rescue_from Exception, with: :handler_500
    rescue_from ActiveRecord::RecordNotFound, with: :handler_404
    rescue_from ActionController::RoutingError, with: :handler_404
  end

  def handler_404(e = nil)
    respond_to do |format|
      format.html { render 'errors/404', status: :not_found, locals: {message: e.try(:message)}}
      format.json { render json: { error: '404 error'}, status: :not_found }
    end
    
  end
  
  def handler_500(e = nil)
    respond_to do |format|
      format.html { render 'errors/500', status: :internal_server_error }
      format.json { render json: { error: '500 error'}, status: :internal_server_error }
    end
  end
end

