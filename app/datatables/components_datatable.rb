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

  def filters
    @filters ||= [
      AjaxDatatables::Filter.new(:value_group) do
        [
          AjaxDatatables::Filter.new(:value_operator, :select, label: '', onchange: :draw,
                                     options: {'=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq}),
          AjaxDatatables::Filter.new(:value, :text_field, label: ''),
        ]
      end,
      ScoresDatatable.new.filters,
    ].flatten
  end
end
