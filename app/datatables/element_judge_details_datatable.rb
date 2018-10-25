class ElementJudgeDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :skater_name, :element_number, :element_name, :value, :average, :number, :panel_name])
    columns.sources = source_mappings
  end

  def fetch_records
    tables = [:element, official: [:panel], element: [:score, score: [:skater]]]
    super.includes(tables).joins(tables)
  end
end
