class PanelsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:panel_name, :text_field),
        filter(:panel_nation, :text_field),
      ]
    end
  end
  ################
  def initialize(*)
    super
    columns([:panel_name, :panel_nation])
    columns.sources = source_mappings.slice(*column_names.map(&:to_sym))

    default_orders([[:panel_name, :asc]])
  end
end
