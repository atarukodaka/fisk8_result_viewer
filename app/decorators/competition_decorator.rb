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
=begin
class SegmentScoreDecorator < CategoryResultDecorator
  def ranking
    h.link_to_score(model.ranking, model)
  end
  self.display_as(:score, [:tss, :tes, :pcs, :deductions])
end
=end
