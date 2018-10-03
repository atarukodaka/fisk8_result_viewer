class SkaterDecorator < EntryDecorator
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to_isu_bio(model.isu_number)
  end
  def isu_records
    h.content_tag(:span) do
      h.concat(h.link_to('Results', 'http://www.isuresults.com/bios/isufs_cr_%08d.htm' % [model.isu_number.to_i], target: :blank))
      h.concat(h.span_link_icon())
      h.concat(' / ')
      h.concat(h.link_to('PB', 'http://www.isuresults.com/bios/isufs_pb_%08d.htm' % [model.isu_number.to_i], target: :blank))
      h.concat(h.span_link_icon())
    end
  end
  def bio_updated_at
    (model.bio_updated_at.present?) ? l(model.bio_updated_at) : ''
  end
end
