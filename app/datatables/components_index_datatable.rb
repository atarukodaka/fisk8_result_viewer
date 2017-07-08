class ComponentsIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    self.columns = 
      [
       {name: "score_name", model: Score, column_name: "name"},
       {name: "competition_name", model: Competition},
       {name: "category", model: Score},
       {name: "segment", model: Score},
       {name: "date", model: Score},
       {name: "season", model: Competition},
       {name: "ranking", model: Score},
       {name: "skater_name", model: Skater, column_name: "name"},
       {name: "nation", model: Skater},
       "number",
       :name,
       :factor, :judges,
       {
         name: "value", filter: ->(v){
           create_arel_table_by_operator(Component, :value, params[:value_operator], v)
         },
       },
      ]
  end
  def fetch_collection
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def create_arel_table_by_operator(model_klass, key, operator_str, value)
    operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      '<' => :lt, '<=' => :lteq}
    operator = operators[operator_str] || :eq
    model_klass.arel_table[key].send(operator, value.to_f)
  end

end
