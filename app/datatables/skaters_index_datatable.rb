class SkatersIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    order = [[:name, :asc]]
    self.columns = [:name, :nation, :category, :isu_number]
  end
    
  def fetch_collection
    Skater.having_scores
  end
end
