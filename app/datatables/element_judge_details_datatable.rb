class ElementJudgeDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :skater_name, :element_name, :value, :panel_name])
  end
  def fetch_records
    ElementJudgeDetail.includes(:element, :panel, element: [:score, score: [:skater]])
  end
end
