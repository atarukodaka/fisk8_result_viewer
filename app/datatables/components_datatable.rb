class ComponentsDatatable < IndexDatatable
  def initialize(view=nil)
    super view

    self.sources = {
      score_name: "scores.name",
      competition_name: "competitions.name",
      season: "competitions.season",
      category: "scores.category",
      segment: "scores.segment",
      date: "scores.date",
      ranking: "scores.ranking",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      name: "components.name",
    }
    add_filters(:skater_name, :competition_name, operator: :matches)
    add_filters(:category, :segment, :nation, :season)

    add_filter(:value) do |c, v|
      c.where(Component.arel_table_by_operator(:value, params[:value_operator], v))
    end
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater]).references(:score, score: [:competition, :skater]).all
  end
  def columns
    
    [:score_name, :competition_name, :category, :segment, :date, :season,
     :ranking, :skater_name, :nation,
     :number, :name, :factor, :judges, :value,]
  end    
  def default_orders
    [[:value, :desc]]
  end

end
