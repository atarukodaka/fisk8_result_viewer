class ElementsDatatable < ScoreDetailsDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:element_name, nil) do
          [
            filter(:name_operator, :select, label: '',  onchange: lambda { |dt| ajax_draw(dt) },
                       options: { '=': :eq, '&sube;'.to_s.html_safe => :matches }),
            filter(:element_name, :text_field, label: ''),
          ]
        end,
        filter(:element_type, nil) do
          [
            filter(:element_type, :select),
            filter(:element_subtype, :select),
          ]
        end,
        filter(:goe, nil) do
          [
            filter(:goe_operator, :select, label: '', onchange: lambda { |dt| ajax_draw(dt) },
                       options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
            filter(:goe, :text_field, label: ''),
          ]
        end,
        ScoresDatatable::Filters.new(datatable: datatable).flatten,
      ].flatten
    end
  end
  ################
  # include IndexDatatable::SeasonFilterable
  def initialize(*)
    super

    columns.add([:number, :element_name, :element_type, :element_subtype,
                 :level, :credit, :info, :base_value, :goe, :judges, :value,])

    columns.sources = {
      element_name: 'elements.name',
      base_value:   'elements.base_value',
    }

    ## searchbale
    [:credit, :info].each { |key| columns[key].searchable = false }

    ## operartor
    if view_context
      columns[:element_name].operator = params[:name_operator].presence || :matches
      columns[:goe].operator = params[:goe_operator].presence || :eq
    end
    columns[:season].operator = params[:season_operator].presence || :eq if view_context
  end

  def fetch_records
    tables = [:score, score: [:competition, :skater, :segment, category: [:category_type]]]
    super.includes(tables).joins(tables)
  end
end
