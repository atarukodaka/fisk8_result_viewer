module LinkToHelper
  def link_to_skater(text = nil, skater)
    link_to(text || skater.name,
            if skater.isu_number
              {controller: :skaters, action: :show, isu_number: skater.isu_number}
            else
              {controller: :skaters, action: :show_by_name, name: skater.name}
            end)
  end
  def link_to_competition(text = nil, competition, category: nil, segment: nil)
    text ||= segment || category || competition.name
    #cid = (competition.class == Competition) ? competition.cid : competition
    link_to(text, {controller: :competitions, action: :show, cid: competition.cid, category: category, segment: segment})
  end

  def link_to_competition_site(text = "SITE", competition)
    content_tag(:span) do
      concat(link_to(text, competition.site_url, target: "_blank"))
      concat(span_link_icon)
    end
  end
  
  def link_to_score(text = nil, score)
    sid = (score.class == Score) ? score.sid : score

    (sid.nil?) ? text : link_to(text || sid, {controller: :scores, action: :show, sid: sid})
  end
  def isu_bio_url(isu_number)
    "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number.to_i]
  end
  def link_to_isu_bio(text = nil, isu_number, target: "_blank")
    text ||= isu_number
    content_tag(:span) do
      concat(link_to(text, isu_bio_url(isu_number), target: target))
      concat(span_link_icon)
    end
  end
  def link_to_pdf(url, target: "_blank")
    img_url = "http://wwwimages.adobe.com/content/dam/acom/en/legal/images/badges/Adobe_PDF_file_icon_24x24.png"
    link_to(image_tag(img_url), url, target: target)
  end
  def link_to_index(text, parameters: {})
    link_to(text, controller: controller_name.to_sym, action: :index, params: parameters)
  end
  def span_link_icon
    content_tag(:span, "", :class => "glyphicon glyphicon-link")
  end
  
  def bracket(str)
    "[#{str}]"
  end
end ## module

module TableHelper
  def tr_data(th, td)
    content_tag(:tr) do
      concat(content_tag(:th, (th.class == Symbol) ? th.to_s.camelize : th))
      concat(content_tag(:td, td))
    end
  end
end

module SortHelper
  def sort_with_preset(data, preset)
    preset_hash = preset.map {|v| [v, false]}.to_h
    to_sort = []
    data.each do |v|
      if preset.include?(v)
        preset_hash[v] = true
      else
        to_sort << v
      end
    end
    preset.select {|v| preset_hash[v]} + to_sort.sort
  end
end
################################################################
module ApplicationHelper
  include LinkToHelper, TableHelper, SortHelper
end
