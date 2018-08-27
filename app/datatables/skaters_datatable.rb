class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category, :nation, :isu_number, :isu_records, :birthday, :age, :club, :coach])
    default_orders([[:category, :asc], [:name, :asc]])
    columns[:age].orderable = false
  end

  def fetch_records
    Skater.having_scores
  end
end
