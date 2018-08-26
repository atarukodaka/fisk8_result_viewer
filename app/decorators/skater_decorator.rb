class SkaterDecorator < EntryDecorator
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.content_tag(:span) do
      h.concat(model.isu_number)
      h.concat(" (")
      h.concat(h.link_to_isu_bio("Biography", model.isu_number))
      h.concat(' / ')
      h.concat(h.link_to("Competition Results", "http://www.isuresults.com/bios/isufs_cr_%08d.htm" % [model.isu_number.to_i], target: :blank))
      h.concat(h.span_link_icon())
      h.concat(' / ')
      h.concat(h.link_to("Personal Best", "http://www.isuresults.com/bios/isufs_pb_%08d.htm" % [model.isu_number.to_i], target: :blank))
      h.concat(h.span_link_icon())
      h.concat(")")
    end


  end
  def isu_records
  end
end

