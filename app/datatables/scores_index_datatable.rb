class ScoresIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    order = [[:category, :asc], [:date, :desc]]
    self.columns =
      [
       {name: "name", model: Competition},
       {name: "competition_name", model: Competition, column_name: "name"},
       :category,
       :segment,
       {name: "season", model: Competition},
       :date, :result_pdf,
       :ranking,
       {name: "skater_name", model: Skater, column_name: 'name'},
       {name: "nation", model: Skater},
       :tss, :tes, :pcs, :deductions, :base_value,
      ]
  end
  
  def fetch_collection
    Score.includes(:competition, :skater).references(:competition, :skater).all
  end
end
