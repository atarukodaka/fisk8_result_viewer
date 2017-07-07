class CompetitionsIndexDatatable < IndexDatatable
  def fetch_collection
    Competition.all
  end
  def create_columns
    [
     :short_name, :name,
     :site_url, :city, :country, :competition_type,
     :season, {name: :start_date, order: :desc}, :end_date,
    ]
  end
end
