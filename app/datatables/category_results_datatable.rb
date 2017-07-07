class CategoryResultsDatatable < Datatable
  def initialize(results: )
    super()
    @results = results
    self.columns = [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss]
  end
  def fetch_collection
    @results.includes(:skater, :scores)
  end
  def create_columns

  end
end
