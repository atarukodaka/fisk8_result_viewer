class CompetitionDecorator < EntryDecorator
  class << self
    def headers
      { competition_type: "Type" }
    end
  end
  def name
    n = h.link_to_competition(model)
    (model.isu_championships) ? h.content_tag(:b, n) : n
  end  
  def site_url
    h.link_to_competition_site("Official", model)
  end
end
################
class CategoryResultDecorator < EntryDecorator
  def skater_name
    h.link_to_skater(nil, model.skater)
  end
  def short_tss
    as_score(model.scores.first.try(:tss))
  end
  def free_tss
    as_score(model.scores.second.try(:tss))
  end
  self.display_as(:ranking, [:short_ranking, :free_ranking])
  self.display_as(:score, [:points])
end

################
class SegmentScoreDecorator < CategoryResultDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
  self.display_as(:score, [:tss, :tes, :pcs, :deductions])
end
