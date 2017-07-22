class ComponentsDatatable < IndexDatatable
  def initialize(view=nil)
    super view

    self.columns = [:score_name, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :factor, :judges, :value,]

    self.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      season: "competitions.season",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      ranking: "scores.ranking",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      name: "components.name",
    }
    self.default_orders = [[:value, :desc]]
    
    ## searchble
    column_defs[:date].searchable = false
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
end
