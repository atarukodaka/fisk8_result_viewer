class ResultDecorator < EntryDecorator
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

  decorate_as_ranking(:ranking)
  decorate_as_score(:points, :short_tes)

  ## short
  def short_ranking
    #h.link_to_competition(model.short_ranking.as_ranking, model.competition, category: model.category, segment: "SHORT")
    h.link_to_score(model.short_ranking.as_ranking, model.short)
  end
  def short_tss
    h.link_to_score(model.short_tss.as_score, model.short)
  end
  decorate_as_score(:short_tes, :short_pcs, :short_deductions, :free_deductions, :short_bv)
  
  ## free
  def free_ranking
    #h.link_to_competition(model.free_ranking.as_ranking, model.competition, category: model.category, segment: "FREE")
    h.link_to_score(model.free_ranking.as_ranking, model.free)
  end
  def free_tss
    h.link_to_score(model.free_tss.as_score, model.free)
  end
  
  decorate_as_score(:free_tes, :free_pcs, :free_deductions, :free_bv)
  decorate_as_score(:total_bv)
  decorate_as_score(:max_points, :max_total_bv, :max_total_goe)  # for statics
  
end

