class ElementsDatatable < ScoreDetailsDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      model = Element
      @data = [
        Filter.new(:element_name, nil, model: model) do
          [
            Filter.new(:name_operator, :select, label: '',  onchange: :draw,
                       options: { '=': :eq, '&sube;'.to_s.html_safe => :matches }),
            Filter.new(:element_name, :text_field, label: ''),
          ]
        end,
        Filter.new(:element_type, nil, model: model) do
          [
            Filter.new(:element_type, :select, model: model),
            Filter.new(:element_subtype, :select, model: model),
          ]
        end,
        Filter.new(:goe, nil, model: model) do
          [
            Filter.new(:goe_operator, :select, label: '', onchange: :draw,
                       options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
            Filter.new(:goe, :text_field, label: ''),
          ]
        end,
        ScoresDatatable::Filters.new.data,
      ].compact.flatten
    end
  end
  ################
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
  end

  def fetch_records
    tables = [:score, score: [:competition, :skater, :segment, category: [:category_type]]]
    super.includes(tables).joins(tables)
  end
end
