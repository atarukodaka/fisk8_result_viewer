class ElementsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :competition_name, :competition_class, :competition_type,
             :category, :segment, :date, :season,
             :skater_name, :nation,
             :number, :name, :element_type, :level, :credit, :info, :base_value, :goe, :judges, :value,])

    columns.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      season: "competitions.season",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      name: "elements.name",
      base_value: "elements.base_value",
    }
    ## searchable
    [:credit, :info, :date].each {|key| columns[key].searchable = false }    

    ## visible
    [:competition_class, :competition_type].each {|key|
      columns[key].visible = false
      columns[key].orderable = false
    }

    ## operartor
    if view_context
      columns[:name].operator = params[:name_operator].presence || :matches
      columns[:goe].operator = params[:goe_operator].presence || :eq
    end
    

    default_orders([[:value, :desc]])
  end

  def fetch_records
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
end
