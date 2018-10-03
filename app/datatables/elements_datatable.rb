class ElementsDatatable < ScoreDetailsDatatable
  def initialize(*)
    super

    columns.add([:number, :element_name, :element_type, :element_subtype, :level, :credit, :info, :base_value, :goe, :judges, :value,])

    columns.sources = {
      element_name: 'elements.name',
      base_value:   'elements.base_value',
    }

    ## searchbale
    [:credit, :info].each {|key| columns[key].searchable = false }

    ## operartor
    if view_context
      columns[:element_name].operator = params[:name_operator].presence || :matches
      columns[:goe].operator = params[:goe_operator].presence || :eq
    end
  end

  def fetch_records
    Element.includes(:score, score: [:competition, :skater, :category, :segment]).references(:score, score: [:competition, :skater, :category, :segment]).all
  end
end
