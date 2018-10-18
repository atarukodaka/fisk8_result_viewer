class PanelsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize
      super([
        Filter.new(:name, :text_field),
        Filter.new(:nation, :text_field),
      ])
    end
  end
  ################
  def initialize(*)
    super
    columns([:name, :nation])

    default_orders([[:name, :asc]])
  end

  def fetch_records
    Panel.all
  end
end
