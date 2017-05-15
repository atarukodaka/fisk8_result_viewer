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
    link_to(text, {controller: :competitions, action: :show, cid: competition.cid, category: category, segment: segment})
  end

  def link_to_score(text = nil, score)
    link_to(text || score.sid, {controller: :scores, action: :show, sid: score.sid})
  end
  def isu_bio_url(isu_number)
    "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number.to_i]
  end
  def link_to_isu_bio(text = nil, isu_number, target: nil)
    text ||= isu_number
    link_to(text, isu_bio_url(isu_number), target: target)
  end

  def link_to_index(text, parameters: {})
    link_to(text, controller: controller_name.to_sym, action: :index, params: parameters)
  end

  ## callbacks for view
  def link_to_pdf_proc(record, key)
    link_to("pdf", record[key])
  end
  def link_to_index_proc(record, key)
    link_to_index(record[key], parameters: params.permit(@filters.keys).merge(key => record[key]))
  end

  def bracket(str)
    "[#{str}]"
  end
end ## module

################################################################
module ApplicationHelper
  include LinkToHelper

end
