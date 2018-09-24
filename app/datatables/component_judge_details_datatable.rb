class ComponentJudgeDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :skater_name, :component_name, :value, :average, :number, :panel_name])

    columns.sources = {
      score_name: "scores.name",
      skater_name: "skaters.name",
      component_name: "components.name",
      panel_name: "panels.name",
    }
  end
  def fetch_records
    ComponentJudgeDetail.includes(:component, official: [:panel], component: [:score, score: [:skater]]).references(:component, :panel, component: [:score, score: [:skater]])
  end
end
