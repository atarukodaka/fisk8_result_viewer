class PanelsController < ApplicationController
  include ControllerConcerns::Index

  def show
    panel = Panel.find_by(name: params[:name]) ||
            raise(ActiveRecord::RecordNotFound.new("no such panel name: '#{params[:name]}'"))

    deviations_relation = Deviation.joins(:official).where("officials.panel_id": panel.id)
    
    summary = {
      name: panel.name,
      nation: panel.nation,
      number_of_participated_segment: PerformedSegment.joins(:officials).where("officials.panel": panel).count,
      number_of_scores_judged: Score.joins(performed_segment: [:officials]).where("officials.panel_id": panel.id).count,
      tes_average_deviation: "%.2f" % [ deviations_relation.average(:tes_deviation) || 0.0 ],
      tes_average_deviation_raio: "%02.2f%" % [ (deviations_relation.average(:tes_ratio) || 0.0) * 100],
      pcs_average_deviation: "%.2f" % [ deviations_relation.average(:pcs_deviation) || 0.0],
      pcs_average_deviation_raio: "%02.2f%" % [ (deviations_relation.average(:pcs_ratio) || 0.0) * 100 ],
    }
    participated_segments_datatable = AjaxDatatables::Datatable.new(self).records(Official.where(panel: panel).includes(performed_segment: [ :competition, :category, :segment ])).columns([:competition_name, :category_name, :segment_name, :number])
    
    columns = [:score_name, :skater_name, :official_number, :tes_deviation, :tes_ratio, :pcs_deviation, :pcs_ratio]
    deviations_datatable = DeviationsDatatable.new(view_context).records(Deviation.where("officials.panel": panel).includes(:official, score: [:skater])).columns(columns)

    respond_to do |format|
      data = { panel: panel, summary: summary, participated_segments_datatable: participated_segments_datatable, deviations_datatable: deviations_datatable }
      format.html {
        render locals: data
      }
      format.json {
        render json: data
      }
    end
  end
end
