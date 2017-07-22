class SkatersDatatable < IndexDatatable
  def initialize(*args)
    super(*args)

    self.columns = [:name, :category, :nation, :isu_number]
    #self.searchable_columns = [:name, :category, :nation]
    self.column_defs[:isu_number].searchable = false
  end

  def fetch_records
    Skater.having_scores
  end
  def default_orders
    [[:category, :asc], [:name, :asc]]
  end
end
