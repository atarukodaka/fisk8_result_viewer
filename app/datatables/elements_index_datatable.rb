class ElementsIndexDatatable < IndexDatatable
  def fetch_collection
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def create_columns
     [
     {name: "score_name", key: "scores.name"},
     {name: "competition_name", key: "competitions.name"},
     {name: "category", key: "scores.category"},
     {name: "segment", key: "scores.category"},
     {name: "date", key: "scores.date"},
     {name: "season", key: "competitions.season"},
     {name: "ranking", key: "scores.ranking"},
     {name: "skater_name", key: "skaters.name"},
     {name: "nation", key: "skaters.nation"},
     "number",
     {name: "name", key: "elements", filter: ->(col, v) {
         (params[:perfect_match]) ? col.where(name: v) : col.where("elements.name like ? ", "%#{v}%")},
     },  # TODO
     "element_type",
     "credit", "info",
     {name: "base_value", key: "elements.base_value"},
     {name: "goe", filter: ->(col, v){
         arel = create_arel_table_by_operator(Element, :goe, params[:goe_operator], v)
         col.where(arel)
       },
     },
     "judges", "value",
    ]
  end
end
