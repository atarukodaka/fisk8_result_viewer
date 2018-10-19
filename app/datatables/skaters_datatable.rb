class SkatersDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:name, :text_field),
        filter(:category_type_name, :select),
        filter(:nation, :select),
        filter(:having_scores, :checkbox, model: Skater, onchange: :draw),
      ]
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
    rec = super.includes(:category_type).references(:category_type)
    (view_context && params[:having_scores] == 'on') ? rec.having_scores : rec
    # (params[:having_scores] == 'on') ? records.having_scores : records
  end
end
