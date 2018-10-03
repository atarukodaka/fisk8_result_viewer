class CompetitionsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:name, :short_name, :site_url, :city, :country, :competition_class, :competition_type, :season, :start_date])
    default_orders([[:start_date, :desc]])
  end

  def fetch_records
    Competition.all
  end
end
