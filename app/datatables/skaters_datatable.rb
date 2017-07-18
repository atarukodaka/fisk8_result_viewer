class SkatersDatatable < IndexDatatable
  def initialize(*args)
    super(*args)

    add_filter(:name, operator: :matches)
    add_filters(:category, :nation)

    #settings.update(order: [[columns.index(:category), :asc], [columns.index(:name), :asc]])
  end

  def columns
    [:name, :category, :nation, :isu_number]
  end

  def fetch_records
    Skater.having_scores
  end

  def order
    [[:category, :asc], [:name, :asc]]
  end
end
