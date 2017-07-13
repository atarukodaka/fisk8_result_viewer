class CompetitionsDatatable < IndexDatatable
  def initialize
    cols = [
            :short_name,
            { name: "name", filter: ->(r, v){ r.where("name like ?", "%#{v}%") }},
            { name: "site_url", filter: ->(r, v){ r.where("site_url": v)}},
            :city, :country,
            { name: "competition_type", filter: ->(r, v){ r.where(competition_type: v)}},
            { name: "season",filter: ->(r, v){ r.where(season: v) }},
            :start_date, :end_date,]
    super(Competition.all, cols)
    @order = [[:start_date, :desc]]
  end
end
