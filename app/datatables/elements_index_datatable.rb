class ElementsIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    self.columns =
      [
       {name: "score_name", model: Score, column_name: "name"},
       {name: "competition_name", model: Competition, column_name: "name"},
       {name: "category", model: Score},
       {name: "segment", model: Score},
       {name: "date", model: Score},
       {name: "season", model: Competition},
       {name: "ranking", model: Score},
       {name: "skater_name", model: Skater, column_name: "name"},
       {name: "nation", model: Skater},
       :number,        
       {name: "name",
         filter: ->(v) {
           (params[:perfect_match]) ? Element.arel_table[:name].eq(v) : Element.arel_table[:name].matches("%#{v}%")
         },  # TODO
       },
       "element_type",
       "credit", "info", :base_value,
       {name: "goe", filter: ->(v){
           create_arel_table_by_operator(Element, :goe, params[:goe_operator], v)
         },
       },
       "judges", "value",
      ]
  end
  def fetch_collection
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def create_columns
  end
end
