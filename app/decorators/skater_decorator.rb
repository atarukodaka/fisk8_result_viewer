class SkatersDecorator < EntriesDecorator
  def column_names
    [ :name, :nation, :category, :isu_number]
  end
end

################################################################
class SkaterDecorator < EntryDecorator
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to_isu_bio(model.isu_number)
  end
end

