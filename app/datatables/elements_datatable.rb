class ElementsDatatable < IndexDatatable
  def initialize(view=nil)
    super view

    self.columns =  [:score_name, :competition_name, :category, :segment, :date, :season,
                     :skater_name, :nation,
                     :number, :name, :element_type, :level, :credit, :info, :base_value, :goe, :judges, :value,]

   
    self.sources = {
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
    [:credit, :info, :date].each {|key| column_defs[key].searchable = false }    
    self.default_orders = [[:value, :desc]]
  end

  def fetch_records
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
end
