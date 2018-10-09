class PanelsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:name, :nation])

    default_orders([[:name, :asc]])
  end

  def fetch_records
    Panel.all
  end

  def filters
    @filters ||= [
      AjaxDatatables::Filter.new(:name, :text_field),
      AjaxDatatables::Filter.new(:nation, :text_field),
    ]
  end
end
