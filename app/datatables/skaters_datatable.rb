class SkatersDatatable < IndexDatatable
  def initialize
    cols = [:name, :category, :nation, :isu_number]
    super(Skater.having_scores, only: cols)

    add_filter(:name, operator: :matches)
    add_filters(:category, :nation)

    add_settings(order: [[cols.index(:category), :asc], [cols.index(:name), :asc]])
  end
end
