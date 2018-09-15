module ScoreVirtualAttributes
  ## virtual attributes for elements/components
  def score_name
    score.name
  end
  def competition_name
    score.competition.name
  end
  def competition_class
    score.competition.competition_class
  end
  def competition_type
    score.competition.competition_type
  end
  def category
    score.category
  end
  def category_type
    score.category.category_type
  end
  def seniority
    score.category.seniority
  end
  def team
    score.category.team
  end
  def segment
    score.segment
  end
  def segment_type
    score.segment.segment_type
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
