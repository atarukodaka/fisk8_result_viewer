class DeviationsController < ApplicationController
  include ControllerConcerns::Index


  def show_panel  ## params[:panel_name]
    panel_name = params[:panel_name]
    columns = [:score_name, :skater_name, :official_number, :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio]
    panel = Panel.find_by(name: panel_name) || raise  # TODO: raise 404
    deviations_datatable = DeviationsDatatable.new(view_context).records(Deviation.where("officials.panel": panel).includes(:official, score: [:skater])).columns(columns)

    render "show_panel", locals: {deviations_datatable: deviations_datatable, panel_name: panel_name}
  end
  
  def show_skater  ## params[:skater_name]
    skater_name = params[:skater_name]
    columns = [:score_name, :panel_name, :official_number, :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio]
    skater = Skater.find_by(name: skater_name)
    deviations_datatable = DeviationsDatatable.new(view_context).records(Deviation.where("scores.skater": skater).includes([official: [ :panel]], :score)).columns(columns)

    render "show_skater", locals: {deviations_datatable: deviations_datatable, skater_name: skater_name}
  end


end
