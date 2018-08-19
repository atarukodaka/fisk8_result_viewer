class CompetitionDecorator < EntryDecorator
  def name
    h.link_to_competition(model)
    #(model.isu_championships) ? h.content_tag(:b, n) : n
  end  
  def site_url
    h.link_to_competition_site("Official", model)
  end
  def timezone
    ActiveSupport::TimeZone[model.timezone || 0].utc_offset/3600
  end
=begin
  def city_country
    [city, country].join(' / ')
  end
  def during
    [start_date.to_s, end_date.to_s].join(' to ')
  end
=end
end

