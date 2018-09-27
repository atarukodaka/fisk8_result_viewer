class PanelsController < ApplicationController
  include ControllerConcerns::Index

  def show
    panel = Panel.find_by(name: params[:name]) ||
            raise(ActiveRecord::RecordNotFound.new("no such panel name: '#{params[:name]}'"))

    summary = {
      name: panel.name,
      nation: panel.nation,
      number_of_participated_segment: PerformedSegment.joins(:officials).where("officials.panel": panel).count,
      number_of_scores_judged: Score.joins(performed_segment: [:officials]).where("officials.panel_id": panel.id).count,
      tes_average_deviation: Deviation.joins(:official).where("officials.panel_id": panel.id).average(:tes_deviation) || 0.0,
      tes_average_deviation_raio: Deviation.joins(:official).where("officials.panel_id": panel.id).average(:tes_ratio) || 0.0,
      pcs_average_deviation: Deviation.joins(:official).where("officials.panel_id": panel.id).average(:pcs_deviation) || 0.0,
      pcs_average_deviation_raio: Deviation.joins(:official).where("officials.panel_id": panel.id).average(:pcs_ratio) || 0.0,
    }
    participated_segments_datatable = AjaxDatatables::Datatable.new(self).records(Official.where(panel: panel).includes(performed_segment: [ :competition, :category, :segment ])).columns([:competition_name, :category, :segment, :number])

    tes_devs = ElementJudgeDetail.where("officials.panel_id": panel.id).includes(:official, [element: [ score: [ :skater ]]]).group("elements.score_id").sum(:abs_deviation)  
    pcs_devs = ComponentJudgeDetail.where("officials.panel_id": panel.id).includes(:official, [component: [ score: [ :skater ]]]).group("components.score_id").sum(:deviation)  
    scores = Score.where(id: tes_devs.keys).includes(:skater).index_by(&:id)
    columns = [:score, :skater, :tes_deviation, :pcs_deviation]
    data = scores.map {|score_id, score|  [score.name, score.skater.name, "%.4f" % [tes_devs[score_id]], "%.4f" % [pcs_devs[score_id]] ]}
    table ={ columns: columns, data: data}
    respond_to do |format|
      format.html {
        render locals: { panel: panel, summary: summary, participated_segments_datatable: participated_segments_datatable, deviation_table: table }
      }
      format.json {
        render json: { summary: summary, }
      }
    end
  end
end
