class ElementsController < ApplicationController
  # for elements/components search
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
  end

  def create_collection
    model_klass = controller_name.singularize.camelize.constantize
    model_klass.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def columns
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
