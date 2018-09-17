class PanelsController < ApplicationController
  include ControllerConcerns::Index

  def show
    panel = Panel.find_by(name: params[:name]) || raise

    respond_to do |format|
      format.html {
        render locals: { panel: panel }
      }
    end
  end
end
