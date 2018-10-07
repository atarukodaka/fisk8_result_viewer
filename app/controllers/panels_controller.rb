class PanelsController < IndexController
  def format_deviation(deviation, in_percentage: false)
    if deviation.nil?
      'n/a'
    elsif in_percentage
      '%02.2f%' % [deviation * 100]
    else
      '%.2f' % [deviation]
    end
  end

  ################
  def show
    panel = Panel.find_by(name: params[:name]) ||
            raise(ActiveRecord::RecordNotFound.new("no such panel name: '#{params[:name]}'"))

    summary = {
      name:                           panel.name,
      nation:                         panel.nation,
      #      number_of_participated_segment:
      #        PerformedSegment.joins(:officials).where("officials.panel": panel).count,
      #      number_of_scores_judged:
      #        Score.joins(performed_segment: [:officials]).where("officials.panel_id": panel.id).count,
    }

    columns = [:competition_name, :category_name, :segment_name, :number]
    records = panel.officials.includes(performed_segment: [:competition, :category, :segment])
    participated_segments_datatable =
      AjaxDatatables::Datatable.new(self).records(records).columns(columns)

    respond_to do |format|
      data = { panel: panel, summary: summary,
               participated_segments_datatable: participated_segments_datatable }
      format.html {
        render locals: data
      }
      format.json {
        render json: data
      }
    end
  end
end
