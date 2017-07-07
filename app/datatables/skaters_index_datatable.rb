class SkatersIndexDatatable < IndexDatatable
  def fetch_collection
    Skater.having_scores
  end
  def create_columns
    [:name, :nation, :category, :isu_number]
  end
end
