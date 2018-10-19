class CompetitionDecorator < EntryDecorator
  def name
    h.link_to_competition(model)
  end

  def name_info
    '%<name>s [%<short_name>s] (%<competition_type>s/%<competition_class>s)' %
      model.attributes.symbolize_keys
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
end
