class PanelsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:name, :text_field, model: Panel),
        filter(:nation, :text_field, model: Panel),
      ]
    end
  end
  ################
  def initialize(*)
    super
    columns([:name, :nation])

    default_orders([[:name, :asc]])
  end
end
