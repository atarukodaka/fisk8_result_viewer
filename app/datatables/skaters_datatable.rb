class SkatersDatatable < IndexDatatable
  def initialize(*args)
    super(*args)

    #add_filter(:name, operator: :matches)
    #add_filters(:category, :nation)
  end

  def fetch_records
    Skater.having_scores
  end

  def columns
    [:name, :category, :nation, :isu_number]
  end
  def searchable_columns
    [:name, :category, :nation]
  end
  def default_orders
    [[:category, :asc], [:name, :asc]]
  end
end
