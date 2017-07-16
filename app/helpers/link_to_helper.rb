module LinkToHelper
=begin
  def link_to_skater_by_isu_number(text = nil, isu_number, params: {})
    link_to(text || isu_number, skater_path(isu_number), params)
  end
=end
  def link_to_skater(text = nil, skater, name: nil, isu_number: nil, params: {})
    isu_number ||= skater[:isu_number]
    name ||= skater[:name]
    text ||= name
    link_to(text, skater_path(isu_number || name), params)
  end

  def link_to_competition(text = nil, competition, category: nil, segment: nil)
    text ||= segment || category || competition.name

    link_to(text, competition_path(competition.short_name, category, segment))
  end
  
  def link_to_competition_site(text = nil, competition)
    text ||= competition.site_url
    content_tag(:span) do
      concat(link_to(text, competition.site_url, target: "_blank"))
      concat(span_link_icon)
    end
  end
  
  def link_to_score(text = nil, score)
    name = (score.class == Score) ? score.name : score

    (name.nil?) ? text : link_to(text || name, score_path(name: name))
    #(name.nil?) ? text : link_to(text || name, {controller: :scores, action: :show, name: name})
  end
  def isu_bio_url(isu_number)
    "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number.to_i]
  end
  def link_to_isu_bio(text = nil, isu_number, target: "_blank")
    text ||= isu_number
    if isu_number.blank?
      "-"
    else
      content_tag(:span) do
        concat(link_to(text, isu_bio_url(isu_number), target: target))
        concat(span_link_icon)
      end
    end
  end
  def link_to_pdf(url, target: "_blank")
    #img_url = "http://wwwimages.adobe.com/content/dam/acom/en/legal/images/badges/Adobe_PDF_file_icon_24x24.png"
    img_url = '/assets/pdf_icon.png'
    link_to(image_tag(img_url), url, target: target)
  end
  def span_link_icon
    content_tag(:span, "", :class => "glyphicon glyphicon-link")
  end
end ## module

