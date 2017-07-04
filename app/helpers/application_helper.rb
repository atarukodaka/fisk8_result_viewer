module LinkToHelper
  def link_to_skater(text = nil, skater, params: {})
    link_to(text || skater[:name], skater_path(skater[:isu_number] || skater[:name]), params)
  end

  def link_to_competition(text = nil, competition, category: nil, segment: nil)
    text ||= segment || category || competition.name

    lt = link_to(text, competition_path(competition.short_name, category, segment))
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

    (name.nil?) ? text : link_to(text || name, score_path(name))
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

module TableHelper
  def tr_data(th, *td)
    content_tag(:tr) do
      concat(content_tag(:th, (th.class == Symbol) ? th.to_s.camelize : th))
      [td].flatten.map {|t|
        concat(content_tag(:td, t))
      }
    end
  end
end

=begin
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
=end
module FilterFormHelper
  using SortWithPreset
  def form_group(label, input_tag = nil)
    content_tag(:div, :class => "form-group row") do
      concat(content_tag(:div, label_tag(label), :class => 'col-sm-2'))
      if block_given?
        concat(content_tag(:div, :class => 'col-sm-10') do
          yield
        end)
      else
        concat(content_tag(:div, input_tag, :class => 'col-sm-10'))
      end
      #concat(yield) if block_given?
    end
  end
  def select_tag_with_options(key, *args)
    col =
      case key
      when :category
        Score.select_options(:category).sort_with_preset(["MEN", "LADIES", "PAIRS", "ICE DANCE"])
      when :segment
        Score.select_options(:segment).sort
      when :nation
        Skater.select_options(:nation).sort
      when :competition_name
        Competition.recent.select_options(:name, :competition_name).sort
      when :competition_type
        Competition.select_options(:competition_type).sort
      when :season
        Competition.select_options(:season).sort.reverse
      when :element_type
        Element.select_options(:element_type).sort
      else
        []
      end
    select_tag(key, options_for_select(col.unshift(nil), selected: params[key]), *args)
  end
  def ajax_search(key, table)  # TODO
    col_num = table.column_names.index(key.to_s)
    "$('##{table.table_id}').DataTable().column(#{col_num}).search(this.value).draw();"
  end
end

=begin
module FormatHelper
  def as_ranking(value)
    (value.to_i == 0) ? "-" : "%d" % [value]
  end
  def as_score(value)
    (value.to_f == 0) ? "-" : "%.2f" % [value]
  end
end
=end
################################################################
module ApplicationHelper
  include LinkToHelper, TableHelper, FilterFormHelper
end
