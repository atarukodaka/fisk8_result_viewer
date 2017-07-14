class ElementsDatatable < IndexDatatable
  def initialize
    data = Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all

    cols = [:score_name, :competition_name, :category, :segment, :date, :season,
            :ranking, :skater_name, :nation,
            :name, :element_type, :credit, :info, :base_value, :goe, :judges, :value,]

   
=begin
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
       
       :number,        
       {name: "name", table: "elements",
         filter: ->(r, v) {
           arel = (params[:perfect_match]) ? Element.arel_table[:name].eq(v) : Element.arel_table[:name].matches("%#{v}%")
           r.where(arel)
         },  # TODO
       },
       "element_type",
       "credit", "info",
       {name: :base_value, table: "elements"},
       {name: "goe", filter: ->(r, v){
           r.where(create_arel_table_by_operator(Element, :goe, params[:goe_operator], v))
         },
       },
       "judges", "value",
      ]
=end
    super(data, only: cols)
    @table_keys = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      ranking: "scores.ranking",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      name: "elements.name",
      base_value: "elements.base_value",
    }
    [:skater_name, :competition_name].each {|k| add_filter(k, operator: :matches) }
    [:category, :segment, :nation, :season].each {|k| add_filter(k)}

    add_filter(:element_type)
    add_filter(:name) do |v|
      arel = (params[:perfect_match]) ? Element.arel_table[:name].eq(v) : Element.arel_table[:name].matches("%#{v}%")
      where(arel)
    end
    add_filter(:goe) do |v|
      where(create_arel_table_by_operator(Element, :goe, params[:goe_operator], v))
    end
    #@order = [[:value, :desc]]
  end
end
