class ElementsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :competition_name, :category, :segment, :date, :season,
             :skater_name, :nation,
             :number, :name, :element_type, :level, :credit, :info, :base_value, :goe, :judges, :value,])

    columns.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
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
