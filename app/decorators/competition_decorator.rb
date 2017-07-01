class CompetitionDecorator < EntryDecorator
  def name
    h.link_to_competition(model)
    #(model.isu_championships) ? h.content_tag(:b, n) : n
  end  
  def site_url
    h.link_to_competition_site("Official", model)
  end
end

