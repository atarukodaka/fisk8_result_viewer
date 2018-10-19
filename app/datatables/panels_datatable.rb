class PanelsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize
      super([
        Filter.new(:name, :text_field, model: Panel),
        Filter.new(:nation, :text_field, model: Panel),
      ])
    end
  end
  ################
  def initialize(*)
    super
    columns([:name, :nation])

    default_orders([[:name, :asc]])
  end
end
