class ScoresDatatable < IndexDatatable
  def initialize(view=nil)
    super view
    self.hidden_columns = [:competition_type, :competition_class, :competition_name,
                          :season, ]
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
    add_filters(:name, :competition_name, :competition_class, :competition_type, :skater_name, operator: :matches)
    add_filters(:category, :segment, :nation, :season)

    update_settings(order: [[columns.index(:date), :desc]])
  end
  def fetch_records
    Score.includes(:competition, :skater).references(:competition, :skater).all
  end
  def columns
    [:name, :competition_name, :competition_class, :competition_type,
     :category, :segment, :season, :date,
     :result_pdf, :ranking, :skater_name, :nation,
     :tss, :tes, :pcs, :deductions, :base_value
    ]
  end
end
