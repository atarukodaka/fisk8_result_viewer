class CompetitionsIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    self.order = [[:start_date, :desc]]
    self.columns =
      [
       :short_name, :name,
       :site_url, :city, :country, :competition_type,
       :season, {name: :start_date, order: :desc}, :end_date,
      ]
  end
  
  def fetch_collection
    Competition.all
  end
end
