class SkaterCompetitionDecorator < EntryDecorator
  include ApplicationHelper
  class << self
    def headers
      {
        short_ranking: "SP#",
        short_tss: "SP-TSS",
        short_tes: "SP-TES",
        short_pcs: "SP-PCS",
        short_deductions: "SP-ded",
        free_ranking: "FS#",
        free_tss: "FS-TSS",
        free_tes: "FS-TES",
        free_pcs: "FS-PCS",
        free_deductions: "FS-ded",
      }
    end
    def column_names
      [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions]
    end
  end
  def competition_name
    h.link_to_competition(nil, model.competition)
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
