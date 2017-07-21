class ElementsDatatable < IndexDatatable
  def initialize(view=nil)
    super view
    
    self.hidden_columns = [:category, :segment, :competition_name, :season]
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
                   name: "elements.name",
                   base_value: "elements.base_value",
                   )
  end
  def fetch_records
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def columns
    [:score_name, :competition_name, :category, :segment, :date, :season,
     :skater_name,
     :number, :name, :element_type, :level, :credit, :info, :base_value, :goe, :judges, :value,]
  end
  def searchable_columns
    [:skater_name, :competition_name, :category, :segment, :nation, :season,
     :element_type, :name, :goe]
  end
  def default_orders
    [[:value, :desc]]
  end
end
