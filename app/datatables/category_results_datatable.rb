class CategoryResultsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:ranking, :skater_name, :nation, :points,
             :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_base_value,
             :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_base_value])

    default_orders([[:points, :desc], [:ranking, :asc]])
  end
end
