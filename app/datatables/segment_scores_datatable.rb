class SegmentScoresDatatable < Datatable
  def initialize(scores:)
    super()
    @scores = scores
    self.columns = [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,]
  end
  def fetch_collection
    @scores.order(:ranking).includes(:skater, :elements, :components)
  end
end
