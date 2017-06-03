class SkaterCompetitionResultSummary
  def initialize(skater, isu_championships_only: false)
    @skater = skater
    @category_results = skater.category_results.isu_championships_only_if(isu_championships_only)
    @isu_champions_only = isu_championships_only
  end
  def highest_score
    @category_results.pluck(:points).compact.max
  end
  def competitions_participated
    @category_results.count
  end
  def gold_won
    @category_results.where(ranking: 1).count
  end
  def highest_ranking
    @category_results.pluck(:ranking).compact.reject {|d| d == 0}.min
  end

  def most_valuable_element
    if (elem = @skater.elements.isu_championships_only_if(@isu_championships_only).order(:value).last)
      "%s %s%s (%.2f=%.2f+%.2f)" % [ elem.name, elem.credit, elem.info, elem.value, elem.base_value, elem.goe]
    else
      "-"
    end
  end
  def most_valuable_components
    @skater.components.isu_championships_only_if(@isu_championships_only).group(:number).maximum(:value).values.join('/')
  end
end

