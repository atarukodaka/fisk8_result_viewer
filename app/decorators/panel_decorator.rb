class PanelDecorator < EntryDecorator
  def name
    h.link_to(model.name, h.panel_path(model.name))
  end
end
