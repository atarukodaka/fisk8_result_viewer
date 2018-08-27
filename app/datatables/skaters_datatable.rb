class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category, :nation, :isu_number, :birthday, :club, :coach])
    default_orders([[:category, :asc], [:name, :asc]])
  end

  def fetch_records
    Skater.having_scores
  end
end
