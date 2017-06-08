class CategorySummaryDecorator < EntryDecorator
  def category
    h.link_to_competition(model.competition, category: model.category)
  end
  def short
    h.link_to_competition(model.competition, category: model.category, segment: model.short)
  end
  def free
    h.link_to_competition(model.competition, category: model.category, segment: model.free)
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
end
