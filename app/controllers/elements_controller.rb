class ElementsController < ApplicationController
  def fetch_rows
    Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
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
     :number,        
     {name: "name", table: "elements",
       filter: ->(v) {
         (params[:perfect_match]) ? Element.arel_table[:name].eq(v) : Element.arel_table[:name].matches("%#{v}%")
       },  # TODO
     },
     "element_type",
     "credit", "info",
     {name: :base_value, table: "elements"},
     {name: "goe", filter: ->(v){
         create_arel_table_by_operator(Element, :goe, params[:goe_operator], v)
       },
     },
     "judges", "value",
    ]
  end
  def order
    [[:value, :desc]]
  end
end
