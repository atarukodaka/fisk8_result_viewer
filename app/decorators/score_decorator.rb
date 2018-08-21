class ScoreDecorator < EntryDecorator
=begin
  def ranking
    h.link_to_score(model.ranking, model)
  end
=end
  def name
    h.link_to_score(model.name, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
  def skater_name
    h.link_to_skater(nil, model.skater, name: model[:skater_name], isu_number: model[:isu_number])
  end
  def competition_name
    h.link_to_competition(model.competition)
  end
  def category
    h.link_to_competition(model.competition, category: model.category)
  end
  def segment
    h.link_to_competition(model.competition, category: model.category, segment: model.segment)
  end
=begin
  def tss
    h.link_to_score(model.tss.as_score, model)
  end
=end
  def scorecalc
    h.link_to(model.name, controller: :scorecalc, score_name: model.name)
  end
  def segment_starting_time
    model.segment_starting_time.in_time_zone(competition.timezone).strftime("%Y-%m-%d %H:%M %z")
  end
=begin
  def youtube_search
    h.link_to("Youtube", "http://www.youtube.com/results?q=" + [score.skater.name, score.competition.name, score.segment].join('+'), target: "_blank")
  end
=end
  decorate_as_ranking(:ranking)
  decorate_as_score(:tss, :tes, :pcs, :deductions, :base_value, :max_tss)
end
