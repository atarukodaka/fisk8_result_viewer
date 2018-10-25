class ComponentsDatatable < ScoreDetailsDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:component_name, :select),
        filter(:value, nil) do
          [
            filter(:value_operator, :select, label: '', onchange: lambda { |dt| ajax_draw(dt) },options: OPERATORS),
            filter(:value, :text_field, label: ''),
          ]
        end,
        *ScoresDatatable::Filters.new(datatable: datatable).to_a,
      ]
    end
  end
  ################
  def initialize(*args)
    super
    columns.add([:component_number, :component_name, :factor, :judges, :value,])

    columns.sources = {
      component_name: 'components.name',
      component_number: 'components.number',
    }
    ## operartors
    if view_context
      columns[:value].operator = params[:value_operator].presence || :eq
      columns[:season].operator = params[:season_operator].presence || :eq
    end
  end

  def fetch_records
    tables = [:score, score: [:competition, :skater, :segment, category: [:category_type]]]
    super.includes(tables).joins(tables)
  end
end
