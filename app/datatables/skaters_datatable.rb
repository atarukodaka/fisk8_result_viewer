class SkatersDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      having_scores_checked =
        (datatable&.view_context) ? datatable.view_context.params[:having_scores] == 'on' : nil

      @data = [
        filter(:name, :text_field),
        filter(:category_type_name, :select),
        filter(:nation, :select),
        filter(:having_scores, :checkbox, onchange: lambda { |dt| ajax_draw(dt) },
               checked: having_scores_checked),
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
  end
end
