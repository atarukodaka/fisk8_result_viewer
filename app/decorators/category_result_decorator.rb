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
    name = model.competition.name
    h.link_to_competition((model.competition.isu_championships) ? h.content_tag(:b, name) : name, model.competition)
  end
  def category
    h.link_to_competition(model.category, model.competition, category: model.category)
  end
  def ranking
    model.ranking.as_ranking
  end
  def points
    #h.link_to_competition(model.points.as_score, model.competition, category: model.category)
    model.points.as_score
  end
  ## short
  def short_ranking
    #h.link_to_competition(model.short_ranking.as_ranking, model.competition, category: model.category, segment: "SHORT")
    h.link_to_score(model.short_ranking.as_ranking, model.short)
  end
  def short_tss
    h.link_to_score(model.short_tss.as_score, model.short)
  end
  def short_tes
    model.short_tes.as_score
  end
  def short_pcs
    model.short_pcs.as_score
  end
  def short_deductions
    model.short_deductions.as_score
  end
  ## free
  def free_ranking
    #h.link_to_score(as_ranking(model.free_ranking), model.scores.first)
    h.link_to_competition(model.free_ranking.as_ranking, model.competition, category: model.category, segment: "FREE")
  end
  def free_tss
    #(s = model.scores.second) ? h.link_to_score(s.tss.as_score, s) : "-"
    h.link_to_score(model.free_tss.as_score, model.free)
  end
  def free_tes
    model.free_tes.as_score
  end
  def free_pcs
    model.free_pcs.as_score
  end
  def free_deductions
    model.free_deductions.as_score
  end
end

