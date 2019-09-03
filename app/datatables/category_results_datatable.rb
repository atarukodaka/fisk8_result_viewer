class CategoryResultsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:ranking, :skater_name, :nation, :points,
             :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions,
             :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions])

    default_orders([[:points, :desc], [:ranking, :asc]])
  end
end
