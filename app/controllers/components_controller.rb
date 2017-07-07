class ComponentsController < ElementsController #  ApplicationController
  def columns
    [
     {name: "score_name", by: "scores.name"},
     {name: "competition_name", by: "competitions.name"},
     {name: "category", by: "scores.category"},
     {name: "segment", by: "scores.segment"},
     {name: "date", by: "scores.date"},
     {name: "season", by: "competitions.season"},
     {name: "ranking", by: "scores.ranking"},
     {name: "skater_name", by: "skaters.name"},
     {name: "nation", by: "skaters.nation"},
     "number",
     {name: "name", by: "components.name"},
     :factor, :judges,
     {
       name: "value", filter: ->(col, v){
         arel = create_arel_table_by_operator(Component, :value, params[:value_operator], v)
         col.where(arel)
       },
     },
    ]
  end
end
