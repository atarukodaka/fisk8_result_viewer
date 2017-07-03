class ElementsController < ApplicationController
  # for elements/components search
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
  end

  def filters
    {
      name: ->(col, v) {
        (params[:perfect_match]) ? col.where(name: v) : col.where("elements.name like ? ", "%#{v}%")
      },
      goe: ->(col, v){
        arel = create_arel_table_by_operator(Element, :goe, params[:goe_operator], v)
        col.where(arel)
      }
    }.merge(score_filters)
  end
  def score_filters
    {
      skater_name: ->(col, v){
        col.includes(score: :skater).references(score: :skater).where("skaters.name like ? ", "%#{v}%")
      },
      category: ->(col, v)   { col.where(scores: {category: v}) },
      segment: ->(col, v)    { col.where(scores: {segment: v}) },
      nation: ->(col, v)     { col.where(skaters: {nation: v}) },
      competition_name: ->(col, v)     { col.where(competitions: {name: v}) },
      isu_championships_only:->(col, v){ col.where(competitions: {isu_championships: v.to_bool }) },
      season: ->(col, v){ col.where(competitions: {season: v}) },
    }
  end
  def create_collection
    model_klass = controller_name.singularize.camelize.constantize
    model_klass.includes(:score, score: [:competition, :skater]).all
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
     {name: "name", table: "elements"},
     "credit", "info",
     {name: "base_value", table: "elements"},
     "goe", "judges", "value",
    ]
  end
end
