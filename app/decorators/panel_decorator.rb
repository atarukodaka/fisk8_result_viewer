class PanelDecorator < EntryDecorator
  def panel_name
    h.link_to(model.name, h.panel_path(model.name))
  end
end
