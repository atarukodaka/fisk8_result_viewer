class ScoresIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    @order = [[:category, :asc], [:date, :desc]]
  end
    
  def fetch_collection
    Score.includes(:competition, :skater).references(:competition, :skater).all
  end
  def create_columns
    [
     {name: "name", by: "scores.name"},
     {name: "competition_name", by: "competitions.name"},
     {name: "category", by: "scores.category"},
     :segment,
     {name: "season", by: "competitions.season"},
     :date, :result_pdf,
     :ranking,
     {name: "skater_name", by: "skaters.name"},
     {name: "nation", by: "skaters.nation"},
     :tss, :tes, :pcs, :deductions, :base_value,
    ]
  end
end
