class DeviationsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :skater_name, :skater_nation, :panel_name, :panel_nation, :official_number, :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio])
    columns.sources ={
      score_name: "scores.name",
      skater_name: "skaters.name",
      skater_nation: "skaters.nation",
      panel_name: "panels.name",
      panel_nation: "panels.nation",
      official_number: "officials.number",
    }
    #columns["no"].numbering = true if columns["no"].present?
    #columns[:no].numbering = true
        
    default_orders([[:tes_deviation_ratio, :desc], [:pcs_deviation_ratio, :desc]])
  end

  def fetch_records
    Deviation.all.includes([official: [:panel]], score: [:skater]).references([official: [:panel]], score: [:skater])
  end
end
