class CategorySummaryDecorator < EntryDecorator
  def category
    h.link_to_competition(model.competition, category: model.category)
  end
  def short
    _segment(:short)
  end
  def free
    _segment(:free)
  end
  def ranker1st
    model.top_rankers.try(:[], 0)
  end
  def ranker2nd
    model.top_rankers.try(:[], 1)
  end
  def ranker3rd
    model.top_rankers.try(:[], 2)
  end
  private
  def _segment(type)
    h.link_to_competition(model.competition, category: model.category, segment: model.send(type))    
  end
end
