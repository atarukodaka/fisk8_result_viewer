class ElementsCsvDecorator < Draper::CollectionDecorator
  def column_names
  end
end

################################################################
class ElementsController < ApplicationController
  # for elements/components search
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    arel = model_klass.arel_table[key].send(operator, value.to_f)
  end


  def filters
    {
      name: ->(col, v) {
        (params[:perfect_match]) ? col.where(name: v) : col.matches("elements.name", v)
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
        col.includes(score: :skater).references(score: :skater).matches("skaters.name", v)
      },
      category: ->(col, v)   { col.where(scores: {category: v}) },
      segment: ->(col, v)    { col.where(scores: {segment: v}) },
      nation: ->(col, v)     { col.includes(score: :skater).where(scores: {skaters: {nation: v}}) },
      #competition_name: ->(col, v)     { col.where(scores: {competitions: {name: v}}) },
      competition_name: ->(col, v)     { col.where(competitions: {name: v}) },
      isu_championships_only:->(col, v){ col.where(competitions: {isu_championships: v.to_bool }) },
      season: ->(col, v){ col.where(competitions: {season: v}) },
    }
  end
  def collection
    model_klass = controller_name.singularize.camelize.constantize
    filter(model_klass.includes(:score, score: [:competition, :skater]).recent)
  end
end
