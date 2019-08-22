class PanelsController < IndexController
=begin
  def format_deviation(deviation, in_percentage: false)
    if deviation.nil?
      'n/a'
    elsif in_percentage
      '%02.2f%' % [deviation * 100]
    else
      '%.2f' % [deviation]
    end
  end
=end
  ################
  def data_to_show
    panel = Panel.find_by!(name: params[:name])

    summary = {
      name:                           panel.name,
      nation:                         panel.nation,
      #      number_of_participated_segment:
      #        PerformedSegment.joins(:officials).where("officials.panel": panel).count,
      #      number_of_scores_judged:
      #        Score.joins(performed_segment: [:officials]).where("officials.panel_id": panel.id).count,
    }

    columns = [:competition_name, :category_name, :segment_name, :function_type, :function]
    #records = panel.officials.includes(performed_segment: [:competition, :category, :segment])
    records = panel.officials.includes(:competition, :category, :segment)
    participated_segments_datatable =
      AjaxDatatables::Datatable.new(self).records(records).columns(columns)

    {
      panel: panel, summary: summary,
      participated_segments_datatable: participated_segments_datatable
    }
  end
end
