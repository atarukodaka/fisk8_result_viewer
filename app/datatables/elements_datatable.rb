class ElementsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :competition_name, :competition_class, :competition_type,
             :category, :segment, :segment_type, :date, :season,
             :skater_name, :nation,
             :number, :name, :element_type, :element_subtype, :level, :credit, :info, :base_value, :goe, :judges, :value,])

    columns.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      season: "competitions.season",
      category: "scores.category",
      segment: "scores.segment",
      segment_type: "scores.segment_type",
      #date: "scores.performed_starting_time.starting_time",
      date: "scores.date",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      name: "elements.name",
      base_value: "elements.base_value",
    }
    ## searchable
    [:date, :credit, :info].each {|key| columns[key].searchable = false }    

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
    Element.includes(:score, score: [:competition, :skater, :category, :segment]).references(:score, score: [:competition, :skater]).all
  end
end
