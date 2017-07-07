class CategoryResultsDatatable < Datatable
  def initialize(results: )
    super(results.includes(:skater, :scores), [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss])
  end

end
