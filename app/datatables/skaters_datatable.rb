class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category_type, :nation, :isu_number, :birthday, :club, :coach])
    columns.sources = {
      category_type: 'categories.category_type',
    }
    default_orders([[:category_type, :asc], [:name, :asc]])
  end

  def filters
    @_filters ||= [
      {
        label: "name",
        fields: [ { key: :name, input_type: :text_field, } ],
      },
      {
        label: "category_type",
        fields: [{ key: :category_type, input_type: :select, }],
      },
      {
        label: "nation",
        fields: [{ key: :nation, input_type: :select, }],
      },
    ]
  end

  def manipulate(r)
    r.having_scores
  end
  def fetch_records
    Skater.includes(:category).references(:category)
  end
end
