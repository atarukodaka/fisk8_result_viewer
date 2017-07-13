class ScoresDatatable < IndexDatatable
  def initialize
    rows = Score.includes(:competition, :skater).references(:competition, :skater).all
    cols =
      [
       {name: "name", table: "scores", filter: ->(r, v){ r.where("name like ?", "%#{v}%") }},
       {name: "competition_name", table: "competitions", column_name: "name", filter: ->(r, v){ r.where("competitions.name like ?", "%#{v}%") }},
       {name: "category", table: "scores", filter: ->(r, v) { r.where(category: v)}},
       {name: "segment", filter: ->(r, v){ r.where(segment: v) }},
       {name: "season", table: "competitions", filter: ->(r, v) { r.where("competitions.season": v)}},
       :date, :result_pdf,
       :ranking,
       {name: "skater_name", table: "skaters", column_name: 'name', filter: ->(r, v){ r.where("skaters.name like ? ", "%#{v}%")}},
       {name: "nation", table: "skaters", filter: ->(r, v){ r.where("skaters.nation": v)}},
       :tss, :tes, :pcs, :deductions,
       {name: "base_value", table: "scores"},
      ]
    super(rows, cols)
    @order = [[:date, :desc], [:category, :asc], [:segment, :desc], [:ranking, :asc]]
  end
end
