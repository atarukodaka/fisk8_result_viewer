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
     {name: "name", key: "scores.name"},
     {name: "competition_name", key: "competitions.name"},
     {name: "category", key: "scores.category"},
     :segment,
     {name: "season", key: "competitions.season"},
     :date, :result_pdf,
     :ranking,
     {name: "skater_name", key: "skaters.name"},
     {name: "nation", key: "skaters.nation"},
     :tss, :tes, :pcs, :deductions, :base_value,
    ]
  end
end
