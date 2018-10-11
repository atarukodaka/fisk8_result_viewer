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
    @filters ||= [
      AjaxDatatables::Filter.new(:name, :text_field, model: Skater),
      AjaxDatatables::Filter.new(:category_type, :select, model: Skater),
      AjaxDatatables::Filter.new(:nation, :select, model: Skater),
      # AjaxDatatables::Filter.new(:having_scores, :checkbox, model: Skater),
    ]
  end

  ################
  def manipulate(records)
    records
    # records.having_scores
  end

  def fetch_records
    Skater.includes(:category).references(:category).having_scores      ## .having_scores
  end
end
