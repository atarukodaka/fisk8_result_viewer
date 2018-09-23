class ScoreDecorator < EntryDecorator

  def ranking
    #h.link_to_score(model.ranking, model)
    h.link_to_competition(model.ranking, model.competition, category: model.category, segment: model.segment, ranking: model.ranking)
  end
  #decorate_as_ranking(:ranking)

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
  def category_name
    h.link_to_competition(model.competition, category: model.category)
  end
  def segment_name
    h.link_to_competition(model.competition, category: model.category, segment: model.segment)
  end
  def segment_type
    model.segment.segment_type
  end
  decorate_as_score(:tss, :tes, :pcs, :deductions, :base_value, :max_tss)
end
