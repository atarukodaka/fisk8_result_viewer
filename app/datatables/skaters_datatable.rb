class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category_type, :nation, :isu_number, :birthday, :club, :coach])
    columns.sources = {
      category_type: 'categories.category_type',
    }
    default_orders([[:category_type, :asc], [:name, :asc]])
  end

  def fetch_records
    Skater.having_scores.includes(:category).references(:category)
  end
end
