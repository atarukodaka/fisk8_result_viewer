class SkatersDatatable < IndexDatatable
  def initialize(view=nil)
    #super(Skater.having_scores, only: cols)
    super(view)

    add_filter(:name, operator: :matches)
    add_filters(:category, :nation)

    update_settings(order: [[columns.index(:category), :asc], [columns.index(:name), :asc]])
  end

  def columns
    [:name, :category, :nation, :isu_number]
  end

  def fetch_records
    Skater.having_scores
  end
end
