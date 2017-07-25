class ComponentsDatatable < IndexDatatable
  def initialize(*args)
    super

    columns([:score_name, :competition_name, :competition_class, :competition_type,
             :category, :segment, :date, :season,
             :ranking, :skater_name, :nation,
             :number, :name, :factor, :judges, :value,])

    columns.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      competition_class: "competitions.class",
      competition_type: "competitions.type",
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
    columns[:value].operator = params[:value_operator].presence || :eq      if view_context

    ## visible
    [:competition_class, :competition_type].each {|key| columns[key].visible = false }

    
    default_orders([[:value, :desc]])
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
end
