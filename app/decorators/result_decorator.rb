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
  decorate_as_score(:points)

  ## short
  def short_score_name
    h.link_to_score(model.short.try(:name), model.short)
  end
=begin
  def short_ranking
    #h.link_to_competition(model.short_ranking.as_ranking, model.competition, category: model.category, segment: "SHORT")
    #h.link_to_score(model.short_ranking.as_ranking, model.short)
    #h.link_to_score(model.short.try(:ranking).as_ranking, model.short)
  end
=end
  decorate_as_ranking(:short_ranking)
  decorate_as_score(:short_tes, :short_pcs, :short_deductions, :free_deductions, :short_bv)
  
  ## free
  def free_score_name
    h.link_to_score(model.short.try(:name), model.short)
  end

=begin
  def free_ranking
    #h.link_to_competition(model.free_ranking.as_ranking, model.competition, category: model.category, segment: "SHORT")
    #h.link_to_score(model.free_ranking.as_ranking, model.short)
    h.link_to_score(model.short.try(:ranking).as_ranking, model.short)
  end
=end
  decorate_as_ranking(:free_ranking)
  decorate_as_score(:free_tes, :free_pcs, :free_deductions, :free_bv)
#  decorate_as_score(:total_bv)
#  decorate_as_score(:max_points, :max_total_bv, :max_total_goe)  # for statics
  
end

