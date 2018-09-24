class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category_name, :nation, :isu_number, :birthday, :club, :coach])
    #default_orders([[:category, :asc], [:name, :asc]])
    columns.sources = {
      category_name: "categories.name",
    }
  end

  def fetch_records
    Skater.having_scores.includes(:category).references(:category)
  end
end
