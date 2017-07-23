module ScoreVirtualAttributes
  ## virtual attributes
  def score_name
    score.name
  end
  def competition_name
    score.competition.name
  end
  def category
    score.category
  end
  def segment
    score.segment
  end
  def date
    score.competition.start_date
  end
  def season
    score.competition.season
  end
  def ranking
    score.ranking
  end
  def skater_name
    score.skater.name
  end
  def nation
    score.skater.nation
  end
end
