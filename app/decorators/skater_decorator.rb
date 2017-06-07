class SkaterDecorator < EntryDecorator
  class << self
    def column_names
      [ :name, :nation, :category, :isu_number]
    end
  end
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to_isu_bio(model.isu_number)
  end

  ################
  # result
  def most_valuable_element
    elem = model.most_valuable_element
    (elem) ? "%s %s%s (%.2f=%.2f+%.2f)" % [ elem.name, elem.credit, elem.info, elem.value, elem.base_value, elem.goe] : "-"
  end
  def most_valuable_components
    model.most_valuable_components.values.join('/')
  end
end

