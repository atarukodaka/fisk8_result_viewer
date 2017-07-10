class CategorySummaryDecorator < Draper::Decorator
  def category
    h.link_to_competition(model.competition, category: model.category)
  end
  def short
    h.link_to_competition(model.competition, category: model.category, segment: model.short)
  end
  def free
    h.link_to_competition(model.competition, category: model.category, segment: model.free)
  end
end
