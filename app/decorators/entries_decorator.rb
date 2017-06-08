class EntriesDecorator < Draper::CollectionDecorator
  def column_names
    object.column_names
  end
end
