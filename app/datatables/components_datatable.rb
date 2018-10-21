class ComponentsDatatable < ScoreDetailsDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:component_name, :select),
        filter(:value, nil) do
          [
            filter(:value_operator, :select, label: '', onchange: lambda {|dt| ajax_draw(dt)},
                       options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
            filter(:value, :text_field, label: ''),
          ]
        end,
        ScoresDatatable::Filters.new(datatable: datatable).data,
      ].flatten
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
