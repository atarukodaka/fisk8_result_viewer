class ComponentsDatatable < IndexDatatable
  def initialize(*args)
    super

    columns([:score_name, :competition_name, :competition_class, :competition_type,
             :category, :segment, :segment_type, :date, :season,
             :ranking, :skater_name, :nation,
             :number, :name, :factor, :judges, :value,])

    columns.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      season: "competitions.season",
      category: "scores.category",
      category: "categories.name",
      segment: "segments.name",
      segment_type: "segments.segment_type",
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
    [:competition_class, :competition_type].each {|key|
      columns[key].visible = false
      columns[key].orderable = false
    }
    columns[:category].operator = :eq

    default_orders([[:value, :desc]])
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater, :category, :segment]).references(:score, score: [:competition, :skater, :category, :segment]).all
  end
end
