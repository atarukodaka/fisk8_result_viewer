class ComponentJudgeDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :skater_name, :component_name, :value, :average, :number, :panel_name])
    columns.sources = source_mappings
  end

  def fetch_records
    tables = [:component, official: [:panel], component: [:score, score: [:skater]]]
    super.includes(tables).joins(tables)
  end
end
