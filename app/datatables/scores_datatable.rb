class ScoresDatatable < IndexDatatable
  def initialize(*args)
    super *args
    
    self.columns = [:name, :competition_name, :competition_class, :competition_type,
     :category, :segment, :season, :date,
     :result_pdf, :ranking, :skater_name, :nation,
     :tss, :tes, :pcs, :deductions, :base_value
    ]

    self.sources = {
      name: "scores.name",
      category: "scores.category",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
    }

    [:competition_type, :competition_class, :competition_name, :season, ].each do |column|
      self.column_defs[column].visible = false
    end
    self.default_orders = [[:date, :desc]]
  end
  def fetch_records
    Score.includes(:competition, :skater).references(:competition, :skater).all
  end
end
