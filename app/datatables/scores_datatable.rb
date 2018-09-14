class ScoresDatatable < IndexDatatable
  def initialize(*)
    super
    
    columns([:name, :competition_name, :competition_class, :competition_type,
             #:category, :category_type, :seniority, :segment, :segment_type, :season, :date,
             :category, :category_type, :indivisual, :seniority, :segment, :segment_type, :season, :date,
             :result_pdf, :ranking, :skater_name, :nation,
             :tss, :tes, :pcs, :deductions, :base_value
             ])
    columns.sources = {
      name: "scores.name",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      category: "categories.name",
      category_type: "categories.category_type",
      indivisual: "categories.indivisual",
      seniority: "categories.seniority",
      segment: "segments.name",
      segment_type: "segments.segment_type",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
    }

    [:competition_type, :competition_class, :competition_name, :season, :category_type, :seniority, :segment_type].each do |key|
      columns[key].visible = false
      columns[key].orderable = false
    end

    columns[:ranking].operator = :eq
    columns[:date].searchable = false
    columns[:category].operator = :eq
    columns[:indivisual].operator = :boolean

    default_orders([[:date, :desc]])
  end
  def fetch_records
    Score.includes(:competition, :skater, :category, :segment).references(:competition, :skater, :category, :segment).all
  end
end
