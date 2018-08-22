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

  decorate_as_ranking(:ranking)
  decorate_as_score(:points)

  ## short
  def short_ranking
    h.link_to_score(model.short.try(:ranking).as_ranking, model.short)
  end
  #decorate_as_ranking(:short_ranking)
  decorate_as_score(:short_tss, :short_tes, :short_pcs, :short_deductions, :free_deductions, :short_bv)
=begin  
  def short_tss
    model.short.tss.as_score
  end
  def short_tes
    model.short.tes.as_score
  end
  def short_pcs
    model.short.pcs.as_score
  end
  def short_deductions
    model.short.deductions.as_score
  end
  def short_bv
    model.short.base_value.as_score
  end
=end

  ## free
  def free_ranking
    h.link_to_score(model.free.try(:ranking).as_ranking, model.free)
  end
=begin
  def free_tss
    model.free.tss.as_score
  end
  def free_tes
    model.free.tes.as_score
  end
  def free_pcs
    model.free.pcs.as_score
  end
  def free_deductions
    model.free.deductions.as_score
  end
  def free_bv
    model.free.base_value.as_score
  end
=end
  #decorate_as_ranking(:free_ranking)
  decorate_as_score(:free_tss, :free_tes, :free_pcs, :free_deductions, :free_bv)
#  decorate_as_score(:total_bv)
#  decorate_as_score(:max_points, :max_total_bv, :max_total_goe)  # for statics
  
end

