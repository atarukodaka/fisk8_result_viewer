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
    tables = [:score, score: [:competition, :skater, :segment, category: [:category_type]]]
    Component.includes(tables).joins(tables)
  end

  def filters
    @filters ||= [
      Filter.new(:value_group) do
        [
          Filter.new(:value_operator, :select, label: '', onchange: :draw,
                                     options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
          Filter.new(:value, :text_field, label: ''),
        ]
      end,
      ScoresDatatable.new.filters,
    ].flatten
  end
end
