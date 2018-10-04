class CompetitionDecorator < EntryDecorator
  def name
    h.link_to_competition(model)
    # (model.isu_championships) ? h.content_tag(:b, n) : n
  end

  def name_info
    "#{model.name} (#{model.competition_type}/#{model.short_name})"
  end

  def location
    "#{city} / #{country}"
  end

  def site_url
    h.link_to_competition_site('Official Site', model)
  end

  def period
    [l(model.start_date), l(model.end_date)].join(' - ') + " [#{model.timezone}]"
  end

  def start_date
    model.start_date
  end

  def end_date
    model.end_date
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
