class SkaterDecorator < EntryDecorator
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to_isu_bio(model.isu_number)
  end

  ################
  # result
  def _category_results
    @_category_results ||= model.category_results.isu_championships_only_if(h.params[:isu_championships_only])
  end
  def highest_score
    _category_results.pluck(:points).compact.max
  end
  def competitions_participated
    _category_results.count
  end
  def gold_won
    _category_results.where(ranking: 1).count
  end
  def highest_ranking
    _category_results.pluck(:ranking).compact.reject {|d| d == 0}.min
  end

  def most_valuable_element
    if (elem = model.elements.isu_championships_only_if(h.params[:isu_championships_only]).order(:value).last)
      "%s %s%s (%.2f=%.2f+%.2f)" % [ elem.name, elem.credit, elem.info, elem.value, elem.base_value, elem.goe]
    else
      "-"
    end
  end
  def most_valuable_components
    model.components.isu_championships_only_if(h.params[:isu_championships_only]).group(:number).maximum(:value).values.join('/')
  end
end

