class ScoreDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :competition_name, :competition_class, :competition_type,
             :category_name, :category_type, :team, :seniority, :segment_name, :segment_type, :date, :season,
             :skater_name, :nation,])

    columns.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      season: "competitions.season",
      category_name: "categories.name",
      category_type: "categories.category_type",
      team: "categories.team",
      seniority: "categories.seniority",
      segment_name: "segments.name",
      segment_type: "segments.segment_type",
      date: "scores.date",
      skater_name: "skaters.name",
      nation: "skaters.nation",
    }
    ## searchable
    columns[:date].searchable = false

    ## visible
    [:competition_class, :competition_type, :category_type, :seniority, :team, :segment_type].each {|key|
      columns[key].visible = false
      columns[key].orderable = false
    }
    ## operatoer
    columns[:category_name].operator = :eq    
    columns[:team].operator = :boolean

    default_orders([[:value, :desc]])
  end
end
