class ApplicationController < ActionController::Base
  include RenderModules
  
  protect_from_forgery with: :exception

  unless Rails.env.development?
  #if Rails.env.production?
    rescue_from Exception, with: :handler_500
    rescue_from ActiveRecord::RecordNotFound, with: :handler_404
    rescue_from ActionController::RoutingError, with: :handler_404
  end
end

def handler_404(e = nil)
  respond_to do |format|
    format.html { render 'errors/404', status: :not_found, locals: {message: e.try(:message)}}
    format.json { render json: { error: '404 error'}, status: :not_found }
  end

end

def handler_500
  respond_to do |format|
    format.html { render 'errors/500', status: :internal_server_error }
    format.json { render json: { error: '500 error'}, status: :internal_server_error }
  end
end
