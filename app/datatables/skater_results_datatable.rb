class SkaterResultsDatatable < Datatable
  def initialize(skater: )
    super()
    @skater = skater
  end
  def fetch_collection
    collection = @skater.category_results.recent.includes(:competition, :scores)
  end
  def create_columns
    [
     :competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,
    ]
  end
end
