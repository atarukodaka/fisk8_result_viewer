class SkaterDecorator < EntryDecorator
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to_isu_bio(model.isu_number)
  end
  def isu_records
    h.content_tag(:span) do
      h.concat(h.link_to("Competition Results", "http://www.isuresults.com/bios/isufs_cr_%08d.htm" % [model.isu_number.to_i], target: :blank))
      h.concat(h.span_link_icon())
      h.concat(' / ')
      h.concat(h.link_to("Personal Best", "http://www.isuresults.com/bios/isufs_pb_%08d.htm" % [model.isu_number.to_i], target: :blank))
      h.concat(h.span_link_icon())
    end
  end
end

