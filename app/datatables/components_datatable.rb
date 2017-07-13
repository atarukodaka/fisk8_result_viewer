class ComponentsDatatable < IndexDatatable
  def initialize
    rows = Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
    cols =
    [
       {name: "score_name", table: "scores", column_name: "name"},
       {name: "competition_name", table: "competitions", column_name: "name", filter: ->(r, v){ r.where("competitions.name like ?", "%#{v}%") }},
       {name: "category", table: "scores", filter: ->(r, v) { r.where("scores.category": v)}},
       {name: "segment", table: "scores", filter: ->(r, v){ r.where("scores.segment": v) }},
       {name: "date", table: "scores"},
       {name: "season", table: "competitions", filter: ->(r, v) { r.where("competitions.season": v)}},
       {name: "ranking", table: "scores"},
       {name: "skater_name", table: "skaters", column_name: "name", filter: ->(r, v){ r.where("skaters.name like ? ", "%#{v}%")}},
       {name: "nation", table: "skaters", filter: ->(r, v){ r.where("skaters.nation": v)}},

     "number",
     {name: "name", table: "components"},
     :factor, :judges,
     {
       name: "value", filter: ->(r, v){
         r.where(create_arel_table_by_operator(Component, :value, params[:value_operator], v))
       },
     },
    ]
    super(rows, cols)
    @order = [[:value, :desc]]
  end
end
