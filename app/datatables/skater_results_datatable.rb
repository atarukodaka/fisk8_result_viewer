class SkaterResultsDatatable < Datatable
  def initialize(skater: )
    collection = skater.category_results.recent.includes(:competition, :scores)
    cols = [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]
    super(collection, cols)
  end
end
