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
            filter(:goe_operator, :select, label: '', onchange: lambda { |dt| ajax_draw(dt) }, options: OPERATORS),
            filter(:goe, :text_field, label: ''),
          ]
        end,
        *ScoresDatatable::Filters.new(datatable: datatable).to_a,
      ]
    end
  end
  ################
  def initialize(*)
    super
    columns.add([:element_number, :element_name, :element_type, :element_subtype,
                 :level, :credit, :info, :base_value, :goe, :judges, :value,])

    columns.sources = {
      element_name: 'elements.name',
      element_number: 'elements.number',
    }
    ## operartors
    if view_context
      columns[:element_name].operator = params[:name_operator].presence || :matches
      columns[:goe].operator = params[:goe_operator].presence || :eq
      columns[:season].operator = params[:season_operator].presence || :eq
    end
  end

  def fetch_records
    tables = [:score, score: [:competition, :skater, :segment, category: [:category_type]]]
    super.includes(tables).joins(tables)
  end
end
