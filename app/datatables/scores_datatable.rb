class ScoresDatatable < IndexDatatable
  def initialize
    collection = Score.includes(:competition, :skater).references(:competition, :skater).all
    cols = [:name, :competition_name, :category, :segment, :season, :date,
            :result_pdf, :ranking, :skater_name, :nation,
            :tss, :tes, :pcs, :deductions, :base_value
           ]
    super(collection, only: cols)
      
    @table_keys = {
      name: "scores.name",
      category: "scores.category",
      competition_name: "competitions.name",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      
    }
    [:name, :competition_name, :skater_name].each {|key| add_filter(key, operator: :matches) }
    [:category, :segment, :nation, :season].each {|key| add_filter(key, operator: :eq)}

    @settings[:order] = [[cols.index(:date), :desc]]
  end
end
