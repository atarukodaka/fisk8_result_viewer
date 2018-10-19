class ComponentsDatatable < ScoreDetailsDatatable
  class Filters < IndexDatatable::Filters
    def initialize
      model = Component
      super([
        Filter.new(:component_name, :select, model: model),
        Filter.new(:value, nil, model: model) do
          [
            Filter.new(:value_operator, :select, label: '', onchange: :draw,
                       options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
            Filter.new(:value, :text_field, label: ''),
          ]
        end,
        ScoresDatatable::Filters.new.data,
      ].flatten)
    end
  end
  ################
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
    super.includes(tables).joins(tables)
  end
end
