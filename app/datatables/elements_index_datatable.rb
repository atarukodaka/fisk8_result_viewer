class ElementsIndexDatatable < IndexDatatable
  def fetch_collection
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def create_columns
     [
     {name: "score_name", by: "scores.name"},
     {name: "competition_name", by: "competitions.name"},
     {name: "category", by: "scores.category"},
     {name: "segment", by: "scores.category"},
     {name: "date", by: "scores.date"},
     {name: "season", by: "competitions.season"},
     {name: "ranking", by: "scores.ranking"},
     {name: "skater_name", by: "skaters.name"},
     {name: "nation", by: "skaters.nation"},
     "number",
     {name: "name", by: "elements", filter: ->(col, v) {
         (params[:perfect_match]) ? col.where(name: v) : col.where("elements.name like ? ", "%#{v}%")},
     },  # TODO
     "element_type",
     "credit", "info",
     {name: "base_value", by: "elements.base_value"},
     {name: "goe", filter: ->(col, v){
         arel = create_arel_table_by_operator(Element, :goe, params[:goe_operator], v)
         col.where(arel)
       },
     },
     "judges", "value",
    ]
  end
end
