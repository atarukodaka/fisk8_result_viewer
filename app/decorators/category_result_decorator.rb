class CategoryResultDecorator < EntryDecorator
  using AsScore
  using AsRanking
  
  def skater_name
    h.link_to_skater(nil, model.skater)
  end
  def nation
    model.skater.nation
  end
  def competition_name
    h.link_to_competition(model.competition)
  end
  def competition_short_name
    h.link_to_competition(model.competition.short_name, model.competition)
  end
  def category
    h.link_to_competition(model.category, model.competition, category: model.category)
  end

  def birthday
    l(model.birthday)
  end
  def bio_updated_at
    l(model.bio_updated_at)
  end

  decorate_as_ranking(:ranking)
  decorate_as_score(:points)

  ## short
  def short_ranking
    h.link_to_score(model.short.try(:ranking).as_ranking, model.short)
  end
  decorate_as_score(:short_tss, :short_tes, :short_pcs, :short_deductions, :short_base_value)

  ## free
  def free_ranking
    h.link_to_score(model.free.try(:ranking).as_ranking, model.free)
  end
  decorate_as_score(:free_tss, :free_tes, :free_pcs, :free_deductions, :free_base_value)
end

