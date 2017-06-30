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
    {
      score_name: "scores.name",
      competition_name: "competitions.name",
      date: "scores.date",
      season: "competitions.season",
      ranking: "scores.ranking",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      number: "number", name: "elements.name", credit: "credit", info: "info",
      base_value: "elements.base_value", goe: "goe", judges: "judges", value: "value",
    }
  end
end
