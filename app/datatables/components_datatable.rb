class ComponentsDatatable < IndexDatatable
  def initialize(view=nil)
    super view

    sources.update(
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
                   )
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def columns
    
    [:score_name, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :factor, :judges, :value,]
  end    
  def searchable_columns
    [:skater_name, :competition_name, :category, :segment, :nation, :season,
     :name, :value]
  end
  def default_orders
    [[:value, :desc]]
  end

end
