class ElementsDatatable < IndexDatatable
  def initialize
    data = Element.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all

    cols = [:score_name, :competition_name, :category, :segment, :date, :season,
            :ranking, :skater_name, :nation,
            :number, :name, :element_type, :credit, :info, :base_value, :goe, :judges, :value,]

    super(data, only: cols)
    @table_keys = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      season: "competitions.season",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      ranking: "scores.ranking",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      name: "elements.name",
      base_value: "elements.base_value",
    }
    add_filters(:skater_name, :competition_name, operator: :matches)
    add_filters(:category, :segment, :nation, :season)

    add_filter(:element_type)
    add_filter(:name) do |c, v|
      arel = (params[:perfect_match]) ? Element.arel_table[:name].eq(v) : Element.arel_table[:name].matches("%#{v}%")
      c.where(arel)
    end
    add_filter(:goe) do |c, v|
      c.where(create_arel_table_by_operator(Element, :goe, params[:goe_operator], v))
    end
    add_settings(order: [[cols.index(:value), :desc]])
  end
end
