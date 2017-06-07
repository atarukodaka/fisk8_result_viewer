class ComponentsController < ElementsController #  ApplicationController
  def filters
    {
      value: ->(col, v){
        arel = create_arel_table_by_operator(Component, :value, params[:value_operator], v)
        col.where(arel)
      }
    }.merge(score_filters)
  end
end
