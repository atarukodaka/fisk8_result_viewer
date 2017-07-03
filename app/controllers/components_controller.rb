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
    [
     {name: :score_name, table: :scores, column_name: :name},
     {name: "competition_name", table: "competitions", column_name: "name"},
     {name: :category, table: :scores},
     {name: :segment, table: :scores},
     {name: :date, table: :scores},
     {name: :season, table: :competitions},
     {name: :ranking, table: :scores},
     {name: :skater_name, table: :skaters, column_name: :name},
     {name: :nation, table: :skaters},
     "number",
     {name: :name, table: :components},
     :factor, :judges, :value,
     ]
  end
end
