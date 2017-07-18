class CompetitionsDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    add_filter(:name, operator: :matches)
    add_filters(:site_url, :competition_type, :competition_class, :season)
    #settings.update(order: [[columns.index(:start_date), :desc]])
  end

  def fetch_records
    Competition.all
  end
  def columns
    [:name, :site_url, :city, :country, :competition_class, :competition_type, :season, :start_date]
  end
  def order
    [[:start_date, :desc]]
  end
end
