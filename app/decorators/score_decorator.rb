class ScoreDecorator < EntryDecorator
  class << self
    def headers
      super.merge({deductions: "ded", result_pdf: "pdf",})
    end
    def column_names
      [:sid, :competition_name, :category, :segment, :season, :date, :result_pdf,
       :ranking, :skater_name, :nation, :tss, :tes, :pcs, :deductions, :base_value]
    end
  end
  def ranking
    h.link_to_score(model.ranking, model)
  end

  def sid
    h.link_to_score(model.sid, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
  def season
    model.competition.season
  end
  def skater_name
    h.link_to_skater(model.skater)
  end
  def nation
    model.skater.nation
  end
  def competition_name
    h.link_to_competition(model.competition)
  end
  def elements_summary
    model.elements.map(&:name).join('/')
  end
  def components_summary
    model.components.map(&:value).join('/')
  end
end
