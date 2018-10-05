class ComponentsDatatable < ScoreDetailsDatatable
  def initialize(*args)
    super

    columns.add([:number, :component_name, :factor, :judges, :value,])
    columns.sources = { component_name: 'components.name', }

    ## searchble
    columns[:date].searchable = false
    columns[:value].operator = params[:value_operator].presence || :eq if view_context
  end

  def fetch_records
    Component.includes(:score, score: [:competition, :skater, :category, :segment])
      .joins(:score, score: [:competition, :skater, :category, :segment]).all
  end
end
