class PanelsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:name, :nation])

    default_orders([[:name, :asc]])
  end

  def fetch_records
    Panel.all
  end
end
