module LinkToHelper
  def link_to_skater(text = nil, skater, params: {})
    link_to(text || skater[:name], skater_path(skater[:isu_number] || skater[:name]), params)
    #link_to(text || skater[:name], url_for(controller: :skaters, action: :show, isu_number: skater[:isu_number] || skater[:name]), params)
  end

  def link_to_competition(text = nil, competition, category: nil, segment: nil)
    text ||= segment || category || competition.name

    lt = link_to(text, competition_path(competition.short_name, category, segment))
    #lt = link_to(text, {controller: :competitions, action: :show, short_name: competition.short_name, category: category, segment: segment})
    (competition.isu_championships) ? lt : content_tag(:i, lt)
  end
  
  def link_to_competition_site(text = "SITE", competition)
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
    img_url = "http://wwwimages.adobe.com/content/dam/acom/en/legal/images/badges/Adobe_PDF_file_icon_24x24.png"
    link_to(image_tag(img_url), url, target: target)
  end
  def span_link_icon
    content_tag(:span, "", :class => "glyphicon glyphicon-link")
  end
end ## module

