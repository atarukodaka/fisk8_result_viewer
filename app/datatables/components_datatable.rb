class ComponentsDatatable < ScoreDetailsDatatable
  def initialize(*args)
    super

    #add_columns([:number, :name, :factor, :judges, :value,])
    columns.add([:number, :name, :factor, :judges, :value,])

    columns.sources = {
      name: "components.name",
    }
    
    ## searchble
    columns[:date].searchable = false
    columns[:value].operator = params[:value_operator].presence || :eq  if view_context
  end
  def fetch_records
    Component.includes(:score, score: [:competition, :skater, :category, :segment]).references(:score, score: [:competition, :skater, :category, :segment]).all
  end
end
