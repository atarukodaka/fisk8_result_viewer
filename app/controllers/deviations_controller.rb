class DeviationsController < ApplicationController
  include ControllerConcerns::Index

  #def show_panel  ## params[:name]
  def panel
    panel_name = params[:name]
    columns = [:score_name, :skater_name, :official_number, :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio]
    panel = Panel.find_by(name: panel_name) || raise(ActiveRecord::RecordNotFound.new("no suck panel: #{panel_name}"))
    #deviations_datatable = DeviationsDatatable.new(view_context).records(Deviation.where("officials.panel": panel).includes(:official, score: [:skater])).columns(columns)
    deviations_datatable = DeviationsDatatable.new(view_context).records(Deviation.where(officials: { panel: panel }).includes(:official, score: [:skater])).columns(columns)

    respond_to do |format|
      format.html {
        render 'show_panel', locals: { deviations_datatable: deviations_datatable, panel_name: panel_name }
      }
      format.json {
        render json: { panel: panel, deviations_datatable: deviations_datatable }
      }
    end
  end

  #def show_skater  ## params[:name]
  def skater
    skater_name = params[:name]
    columns = [:score_name, :panel_name, :official_number, :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio]
    skater = Skater.find_by(name: skater_name)
    deviations_datatable = DeviationsDatatable.new(view_context).records(Deviation.where("scores.skater": skater).includes([official: [:panel]], :score)).columns(columns)

    respond_to do |format|
      format.html {
        render 'show_skater', locals: { deviations_datatable: deviations_datatable, skater_name: skater_name }
      }
      format.json {
        render json: { skater: skater, deviations_datatable: deviations_datatable }
      }
    end
  end
end
