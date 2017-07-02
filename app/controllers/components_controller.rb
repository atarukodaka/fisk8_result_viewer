class ComponentsController < ElementsController #  ApplicationController
  def filters
    {
      value: ->(col, v){
        arel = create_arel_table_by_operator(Component, :value, params[:value_operator], v)
        col.where(arel)
      }
    }.merge(score_filters)
  end
  def columns
    {
      score_name: "scores.name",
      competition_name: "competitions.name",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      season: "competitions.season",
      ranking: "scores.ranking",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      number: "number", name: "components.name", factor: "factor",
      judges: "judges", value: "value",
    }
  end

end
