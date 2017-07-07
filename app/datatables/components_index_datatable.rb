class ComponentsIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    self.columns = 
      [
       {name: "score_name", key: "scores.name"},
       {name: "competition_name", key: "competitions.name"},
       {name: "category", key: "scores.category"},
       {name: "segment", key: "scores.segment"},
       {name: "date", key: "scores.date"},
       {name: "season", key: "competitions.season"},
       {name: "ranking", key: "scores.ranking"},
       {name: "skater_name", key: "skaters.name"},
       {name: "nation", key: "skaters.nation"},
       "number",
       {name: "name", key: "components.name"},
       :factor, :judges,
       {
         name: "value", filter: ->(col, v){
           arel = create_arel_table_by_operator(Component, :value, params[:value_operator], v)
           col.where(arel)
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
