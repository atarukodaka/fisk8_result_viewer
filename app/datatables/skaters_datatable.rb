class SkatersDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:name, :category_type_name, :nation, :isu_number, :birthday, :club, :coach])
    columns.sources = {
      category_type_name: 'category_types.name',
    }
    default_orders([[:category_type_name, :asc], [:name, :asc]])
  end

  def filters
    @filters ||= [
      Filter.new(:name, :text_field, model: Skater),
      Filter.new(:category_type_name, :select, model: Skater),
      Filter.new(:nation, :select, model: Skater),
      #Filter.new(:having_scores, :checkbox, model: Skater, onchange: :draw),
    ]
  end

  ################
  def manipulate(records)
    records
  end

  def fetch_records
    records = Skater.all.includes(:category_type).references(:category_type)
    #(params[:having_scores] == 'on') ? records.having_scores : records
    #(params[:having_scores] == 'on') ? records.having_scores : records
  end
end
