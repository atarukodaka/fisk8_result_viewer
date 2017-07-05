class CategoryResultDecorator < EntryDecorator
  using AsScore
  using AsRanking
  
  def skater_name
    h.link_to_skater(nil, model.skater)
  end
  def nation
    model.skater.nation
  end
=begin  
  def short_tss
    as_score(model.scores.first.try(:tss))
  end
  def free_tss
    as_score(model.scores.first.try(:tss))
  end
  self.display_as(:ranking, [:short_ranking, :free_ranking])
  self.display_as(:score, [:points])
=end
  def competition_name
    name = model.competition.name
    h.link_to_competition((model.competition.isu_championships) ? h.content_tag(:b, name) : name, model.competition)
  end
  def ranking
    #h.link_to_competition(as_ranking(model.ranking), model.competition, category: model.category)
    h.link_to_competition(model.ranking.as_ranking, model.competition, category: model.category)
  end
  def points
    h.link_to_competition(model.points.as_score, model.competition, category: model.category)
  end
  ## short
  def short_ranking
    h.link_to_competition(model.short_ranking.as_ranking, model.competition, category: model.category, segment: "SHORT")
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
    model.free_tss.as_score
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

