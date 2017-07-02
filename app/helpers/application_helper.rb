using ToDirection

module LinkToHelper
  def link_to_skater(text = nil, skater, params: {})
    link_to(text || skater[:name], skater_path(skater[:isu_number] || skater[:name]), params)
  end

  def link_to_competition(text = nil, competition, category: nil, segment: nil)
    text ||= segment || category || competition.name

    lt = link_to(text, competition_path(competition.short_name, category, segment))
    #(competition.isu_championships && category.nil?) ? content_tag(:b, lt) : lt
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
  def link_to_table_header(header)
    query = params.permit(controller.filters.keys).to_hash.symbolize_keys.merge({sort: header})
    if params[:sort] == header.to_s
      direction = params[:direction].to_direction
      query.merge!({direction: direction.opposit})
      updown = (direction.current == :asc) ? :down : :up
      content_tag(:span) do
        link_to(query) do
          concat(header.to_s.camelize)
          concat(content_tag(:i, nil, :class => "glyphicon glyphicon-arrow-#{updown}"))
        end
      end
    else
      link_to(header.to_s.camelize, query)
    end
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

module FilterFormHelper
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
  def select_tag_with_options(key, col = nil, options: {})
    if col.nil?
      col =
        case key
        when :category
          sort_with_preset(Score.select_options(:category), ["MEN", "LADIES", "PAIRS", "ICE DANCE"])
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
        end
    end
    select_tag(key, options_for_select(col.unshift(nil), selected: params[key]), options)
  end
  def ajax_search(key, table)  # TODO
    cols = (table) ? table.columns : controller.columns
    col_num = table.column_names.index(key)
    "$('##{table.table_id}').DataTable().column(#{col_num}).search(this.value).draw();"
  end
end

module FormatHelper
  def as_ranking(value)
    (value.to_i == 0) ? "-" : "%d" % [value]
  end
  def as_score(value)
    (value.to_f == 0) ? "-" : "%.2f" % [value]
  end
end

################################################################
module ApplicationHelper
  include LinkToHelper, TableHelper, SortHelper, FormatHelper, FilterFormHelper
end
