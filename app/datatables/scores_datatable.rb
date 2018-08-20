class ScoresDatatable < IndexDatatable
  def initialize(*)
    super
    
    columns([:name, :competition_name, :competition_class, :competition_type,
             :category, :segment, :season, :segment_starting_time,
             :result_pdf, :ranking, :skater_name, :nation,
             :tss, :tes, :pcs, :deductions, :base_value
             ])
    columns.sources = {
      name: "scores.name",
      category: "scores.category",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
    }

    [:competition_type, :competition_class, :competition_name, :season, ].each do |key|
      columns[key].visible = false
      columns[key].orderable = false
    end

    columns[:ranking].operator = :eq
    columns[:segment_starting_time].searchable = false

    default_orders([[:segment_starting_time, :desc]])
  end
  def fetch_records
    Score.includes(:competition, :skater).references(:competition, :skater).all
  end
end
