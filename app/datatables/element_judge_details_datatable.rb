class ElementJudgeDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :skater_name, :element_number, :element_name, :value, :average, :number, :panel_name])

    columns.sources = {
      score_name: "scores.name",
      skater_name: "skaters.name",
      element_number: "elements.number",
      element_name: "elements.name",
      panel_name: "panels.name",
    }
  end
  def fetch_records
    ElementJudgeDetail.includes(:element, official: [:panel], element: [:score, score: [:skater]]).references(:element, :panel, element: [:score, score: [:skater]])
  end
end