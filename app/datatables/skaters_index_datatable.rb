class SkatersIndexDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    @order = [[:name, :asc]]
  end
    
  def fetch_collection
    Skater.having_scores
  end
  def create_columns
    [:name, :nation, :category, :isu_number]
  end
end
