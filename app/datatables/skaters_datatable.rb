class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category, :nation, :isu_number, :birthday, :club, :coach])
    #default_orders([[:category, :asc], [:name, :asc]])
    columns.sources = {
      category: "categories.name",
    }
  end

  def fetch_records
    Skater.having_scores.includes(:category).references(:category)
  end
end
