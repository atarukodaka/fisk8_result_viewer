class ComponentsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :competition_name, :category, :segment, :date, :season,
             :ranking, :skater_name, :nation,
             :number, :name, :factor, :judges, :value,])

    columns.sources = {
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
  
    ## searchble
    columns[:date].searchable = false
    columns[:value].operator = params[:value_operator].presence || :eq

    default_orders([[:value, :desc]])
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
end
