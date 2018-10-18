class SkatersDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize
      super([
        Filter.new(:name, :text_field, model: Skater),
        Filter.new(:category_type_name, :select, model: Skater),
        Filter.new(:nation, :select, model: Skater),
        Filter.new(:having_scores, :checkbox, model: Skater, onchange: :draw),
      ])
    end
  end
  ################
  def initialize(*)
    super

    columns([:name, :category_type_name, :nation, :isu_number, :birthday, :club, :coach])
    columns.sources = {
      category_type_name: 'category_types.name',
    }
    default_orders([[:category_type_name, :asc], [:name, :asc]])
  end

  ################
  def manipulate(rec)
    rec
  end

  def fetch_records
    rec = Skater.all.includes(:category_type).references(:category_type)
    (view_context && params[:having_scores] == 'on') ? rec.having_scores : rec
    # (params[:having_scores] == 'on') ? records.having_scores : records
  end
end
