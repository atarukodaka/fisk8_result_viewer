class ElementsDatatable < ScoreDetailsDatatable
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
    tables = [:score, score: [:competition, :skater, :category, :segment]]
    Element.includes(tables).joins(tables)
  end

  def filters
    @filters ||= [
      ScoresDatatable.new.filters,
      AjaxDatatables::Filter.new(:element_name_group) do
        [
          AjaxDatatables::Filter.new(:name_operator, :select, label: '',  onchange: :draw,
                                     options: { '=': :eq, '&sube;'.to_s.html_safe => :matches }),
          AjaxDatatables::Filter.new(:element_name, :text_field, label: ''),
        ]
      end,
      AjaxDatatables::Filter.new(:element_type_group) do
        [
          AjaxDatatables::Filter.new(:element_type, :select),
          AjaxDatatables::Filter.new(:element_subtype, :select),
        ]
      end,
      AjaxDatatables::Filter.new(:goe_group) do
        [
          AjaxDatatables::Filter.new(:goe_operator, :select, label: '', onchange: :draw,
                                     options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
          AjaxDatatables::Filter.new(:goe, :text_field, label: ''),
        ]
      end,
    ].flatten
  end
end
