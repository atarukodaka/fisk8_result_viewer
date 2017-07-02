class ApplicationController < ActionController::Base
  ## for ajax request
  def list
    respond_to do |format|
      format.json {
        table = create_datatable.tap {|t| t.paging = true }
        render json: {
          iTotalRecords: table.collection.model.count,
          iTotalDisplayRecords: table.collection.total_count,
          data: table.collection.decorate.map {|d| table.columns.keys.map {|k| [k, d.send(k)]}.to_h },
        }
      }
    end
  end

  ################################################################
  protect_from_forgery with: :exception
  include IndexActionModules

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
      format.json { render json: { error: '500 error'}, status: :internal_server_error, locals: {message: e.try(:message)}}
    end
  end
  
end

