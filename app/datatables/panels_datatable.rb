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
      Filter.new(:name, :text_field),
      Filter.new(:nation, :text_field),
    ]
  end
end
