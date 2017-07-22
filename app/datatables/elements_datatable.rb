class ElementsDatatable < IndexDatatable
  def initialize(view=nil)
    super view

    self.columns =  [:score_name, :competition_name, :category, :segment, :date, :season,
     :skater_name, :nation,
     :number, :name, :element_type, :level, :credit, :info, :base_value, :goe, :judges, :value,]

    columns_to_search = [:skater_name, :competition_name, :category, :segment, :season,
                         :element_type, :name, :goe]

    (self.columns - columns_to_search).each do |key|
      self.column_defs[key].searchable = false
    end

    self.hidden_columns = [:category, :segment, :competition_name, :season]
    self.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      season: "competitions.season",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      skater_name: "skaters.name",
      name: "elements.name",
      base_value: "elements.base_value",
    }
  end
  def fetch_records
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def default_orders
    [[:value, :desc]]
  end
end
