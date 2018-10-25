class ElementJudgeDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :skater_name, :value, :number, :panel_name])
    columns.sources = source_mappings
  end
  def default_model
    JudgeDetail
  end
  def fetch_records
    tables = [:detailable, official: [:panel], detailable: [:score, score: [:skater]]]
    #super.includes(tables).joins(tables)
    super.preload(tables)  # .joins(tables)
  end
end
