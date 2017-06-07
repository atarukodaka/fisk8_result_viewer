class CompetitionDecorator < EntryDecorator
  class << self
    def column_names
      [:cid, :name, :site_url, :city, :country, :competition_type, :season, :start_date, :end_date]      
    end
  end
  def name
    n = h.link_to_competition(model)
    (model.isu_championships) ? h.content_tag(:b, n) : n
  end  
  def site_url
    h.link_to_competition_site("Official", model)
  end
end

