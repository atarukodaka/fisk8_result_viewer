class CompetitionsDatatable < IndexDatatable
  def initialize
    cols = [:name, :site_url, :city, :country, :competition_class, :competition_type, :season, :start_date, :end_date]
    super(Competition.all, only: cols)
    
    add_filter(:name, operator: :matches)
    add_filters(:site_url, :competition_type, :competition_class, :season)
    update_settings(order: [[cols.index(:start_date), :desc]])
  end
end
