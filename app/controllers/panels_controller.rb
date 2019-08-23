class PanelsController < IndexController
  def data_to_show
    panel = Panel.find_by!(name: params[:name])

    summary = {
      name:                           panel.name,
      nation:                         panel.nation,
    }

    columns = [:competition_name, :category_name, :segment_name, :function_type, :function]
    records = panel.officials.includes(:competition, :category, :segment)
    participated_segments_datatable =
      AjaxDatatables::Datatable.new(self).records(records).columns(columns)

    {
      panel: panel, summary: summary,
      participated_segments_datatable: participated_segments_datatable
    }
  end
end
