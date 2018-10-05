class DeviationsController < IndexController
  def show_panel
    panel_name = params[:name]
    panel = Panel.find_by(name: panel_name) ||
            raise(ActiveRecord::RecordNotFound.new("no suck panel: #{panel_name}"))
    records = Deviation.where(officials: { panel: panel }).includes(:official, score: [:skater])
    columns = [:score_name, :skater_name, :official_number,
               :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio]
    deviations_datatable = DeviationsDatatable.new(view_context).records(records).columns(columns)

    respond_to do |format|
      format.html {
        render 'show_panel', locals: { deviations_datatable: deviations_datatable, panel_name: panel_name }
      }
      format.json {
        render json: { panel: panel, deviations_datatable: deviations_datatable }
      }
    end
  end

  # def show_skater  ## params[:name]
  def show_skater
    skater_name = params[:name]
    skater = Skater.find_by(name: skater_name)
    records = Deviation.where("scores.skater": skater).includes([official: [:panel]], :score)
    columns = [:score_name, :panel_name, :official_number,
               :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio]
    deviations_datatable = DeviationsDatatable.new(view_context).records(records).columns(columns)

    respond_to do |format|
      format.html {
        render 'show_skater',
               locals: { deviations_datatable: deviations_datatable, skater_name: skater_name }
      }
      format.json {
        render json: { skater: skater, deviations_datatable: deviations_datatable }
      }
    end
  end
end
