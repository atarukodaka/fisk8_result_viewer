module LinkToHelper
  # rubocop:disable Style/OptionalArguments
  def link_to_skater(text = nil, skater, name: nil, isu_number: nil, params: {})
    isu_number ||= skater[:isu_number]
    name ||= skater[:name]
    text ||= name
    link_to(text, skater_path(isu_number || name), params)
  end

  def link_to_competition(text = nil, competition, category: nil, segment: nil, ranking: nil)
    # text ||= segment || category || competition.name
    text ||= segment.try(:name) || category.try(:name) || competition.name
    link_to(text, competition_path(competition.short_name, category.try(:name), segment.try(:name), ranking))
  end

  def link_to_competition_site(text = nil, competition)
    text ||= competition.site_url
    content_tag(:span) do
      concat(link_to(text, competition.site_url, target: '_blank'))
      concat(span_link_icon)
    end
  end

  def link_to_score(text = nil, score)
    name = (score.class == Score) ? score.name : score

    (name.nil?) ? text : link_to(text || name, score_path(name: name))
    # (name.nil?) ? text : link_to(text || name, {controller: :scores, action: :show, name: name})
  end

  def link_to_panel(text = nil, panel)
    link_to(text || panel.name, panel_path(name: panel.name))
  end

  def isu_bio_url(isu_number)
    'http://www.isuresults.com/bios/isufs%08d.htm' % [isu_number.to_i]
  end

  def link_to_isu_bio(text = nil, isu_number, target: '_blank')
    text ||= isu_number
    if isu_number.blank?
      '-'
    else
      content_tag(:span) do
        concat(link_to(text, isu_bio_url(isu_number), target: target))
        concat(span_link_icon)
      end
    end
  end

  def link_to_pdf(url, target: '_blank')
    link_to(image_tag(asset_path('pdf_icon.png')), url, target: target)
  end

  def span_link_icon
    content_tag(:span, '', class: 'glyphicon glyphicon-link')
  end

  # rubocop:enable Style/OptionalArguments
end ## module
