class CompetitionDecorator < EntryDecorator
  def name
    h.link_to_competition(model)
    #(model.isu_championships) ? h.content_tag(:b, n) : n
  end  
  def site_url
    h.link_to_competition_site("Official", model)
  end
  def categories
    model.categories.map {|category| h.link_to_competition(model, category: category)}.join(', ').html_safe
  end
end

