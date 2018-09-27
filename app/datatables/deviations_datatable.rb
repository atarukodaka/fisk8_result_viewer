class DeviationsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :skater_name, :panel_name, :tes_deviation, :tes_ratio, :pcs_deviation, :pcs_ratio])
    columns.sources ={
      score_name: "scores.name",
      skater_name: "skaters.name",
      panel_name: "panels.name",
    }
    #columns["no"].numbering = true if columns["no"].present?
    #columns[:no].numbering = true
        
    default_orders([[:tes_ratio, :desc], [:pcs_ratio, :desc]])
  end

  def fetch_records
    Deviation.all.includes(:panel, score: [:skater])
  end
end
