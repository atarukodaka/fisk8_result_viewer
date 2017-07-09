class ComponentsController < ApplicationController
  def fetch_rows
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end

  def columns
    [
     {name: "score_name", table: "scores", column_name: "name"},
     {name: "competition_name", table: "competitions", column_name: "name"},
     {name: "category", table: "scores"},
     {name: "segment", table: "scores"},
     {name: "date", table: "scores"},
     {name: "season", table: "competitions"},
     {name: "ranking", table: "scores"},
     {name: "skater_name", table: "skaters", column_name: "name"},
     {name: "nation", table: "skaters"},
     "number",
     {name: "name", table: "components"},
     :factor, :judges,
     {
       name: "value", filter: ->(v){
         create_arel_table_by_operator(Component, :value, params[:value_operator], v)
       },
     },
    ]
  end
  def order
    [[:value, :desc]]
  end
end
