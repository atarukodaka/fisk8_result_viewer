class CategoryResult < ApplicationRecord
  ## relations
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater

  ## methods
  def competition_name
    competition.name
  end
  def skater_name
    skater.name
  end
  def nation
    skater.nation
  end
  def date
    competition.start_date
  end
  def short
    scores.first   ## segment =~ /SHORT/
  end
  def short_tss
    short.try(:tss)
  end
  def short_tes
    short.try(:tes)
  end
  def short_pcs
    short.try(:pcs)
  end
  def short_deductions
    short.try(:deductions)
  end
  def free
    scores.second
  end
  def free_tss
    free.try(:tss)
  end
  def free_tes
    free.try(:tes)
  end
  def free_pcs
    free.try(:pcs)
  end
  def free_deductions
    free.try(:deductions)
  end
  
  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }

  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end

  class << self
    def find_by_segment_ranking(segment, ranking)
      ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
      where(ranking_type => ranking).first
    end
    def create_category_result(result_url, competition, category, parser: nil)
      parser ||= Parsers.get_parser(competition.parser_type.to_sym)
      parser.parse(:category_result, result_url).each do |result|
        competition.category_results.create do |cr|
          cr.attributes = result.except(:skater_name, :nation)
          cr.category = category
          cr.skater = Skater.find_or_create_by_isu_number_or_name(cr.isu_number, result[:skater_name]) do |sk|
            sk.attributes = {
              category: category.sub(/^JUNIOR */, ''),
              nation: result[:nation],
            }
          end
          puts cr.summary
        end
      end
    end
    def highest_score
      pluck(:points).compact.max
    end
    def highest_ranking
      pluck(:ranking).compact.reject {|d| d == 0}.min
    end
  end
end
