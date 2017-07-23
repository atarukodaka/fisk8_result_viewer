class SkatersDatatable < IndexDatatable
  def initialize(*args)
    super(*args)

    self.columns = [:name, :category, :nation, :isu_number]
    self.default_orders = [[:category, :asc], [:name, :asc]]
  end

  def fetch_records
    Skater.having_scores
  end
end
