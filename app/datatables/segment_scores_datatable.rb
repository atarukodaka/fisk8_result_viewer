class SegmentScoresDatatable < Datatable
  def initialize(scores:)
    super(scores.order(:ranking).includes(:skater, :elements, :components), [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary])
  end
end
