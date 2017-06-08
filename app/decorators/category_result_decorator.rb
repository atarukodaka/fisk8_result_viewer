class CategoryResultDecorator < EntryDecorator
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
  def date
    model.competition.start_date
  end
  def ranking
    h.link_to_competition(as_ranking(model.ranking), model.competition, category: model.category)
  end
  def points
    h.link_to_competition(as_score(model.points), model.competition, category: model.category)
  end
  ## short
  def short_ranking
    #h.link_to_score(as_ranking(model.short_ranking), model.scores.first)
    h.link_to_competition(as_ranking(model.short_ranking), model.competition, category: model.category, segment: "SHORT")
  end
  def short_tss
    (s = model.scores.first) ? h.link_to_score(as_score(s.tss), s) : "-"
  end
  def short_tes
    (s = model.scores.first) ? as_score(s.tes) : "-"
  end
  def short_pcs
    (s = model.scores.first) ? as_score(s.pcs) : "-"    
  end
  def short_deductions
    (s = model.scores.first) ? as_score(s.deductions) : "-"    
  end

  ## free
  def free_ranking
    #h.link_to_score(as_ranking(model.free_ranking), model.scores.first)
    h.link_to_competition(as_ranking(model.free_ranking), model.competition, category: model.category, segment: "FREE")
  end
  def free_tss
    (s = model.scores.second) ? h.link_to_score(as_score(s.tss), s) : "-"
  end
  def free_tes
    (s = model.scores.second) ? as_score(s.tes) : "-"
  end
  def free_pcs
    (s = model.scores.second) ? as_score(s.pcs) : "-"
  end
  def free_deductions
    (s = model.scores.second) ? as_score(s.deductions) : "-"
  end

  
end

