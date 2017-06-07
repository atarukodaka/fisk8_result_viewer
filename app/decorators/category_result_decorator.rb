class CategoryResultDecorator < EntryDecorator
  def skater_name
    h.link_to_skater(nil, model.skater)
  end
  def nation
    model.skater.nation
  end
  def short_tss
    as_score(model.scores.first.try(:tss))
  end
  def free_tss
    as_score(model.scores.first.try(:tss))
  end
  self.display_as(:ranking, [:short_ranking, :free_ranking])
  self.display_as(:score, [:points])
end

