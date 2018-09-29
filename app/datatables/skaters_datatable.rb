class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category_name, :nation, :isu_number, :birthday, :club, :coach])
    columns.sources = {
      category_name: "categories.name",
    }
    default_orders([[:category_name, :asc], [:name, :asc]])
  end

  def fetch_records
    Skater.having_scores.includes(:category).references(:category)
  end
end
