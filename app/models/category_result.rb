class CategoryResult < ApplicationRecord
  before_save :save_skater
  ## relations
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater
  
  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }
  scope :top_rankers, ->(n) { where("ranking > 0 and ranking <= ? ", n.to_i).order(:ranking) }
  scope :search_by_skater_name_or_segment_ranking, ->(skater_name:, segment:, ranking: ){
    ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
    joins(:skater).where("skaters.name" => skater_name).presence || where(ranking_type => ranking)
  }
  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end

  class << self
    def create_category_result(result_url, competition, category, parser: nil)
      parser ||= Parsers.get_parser(competition.parser_type.to_sym)
      parser.parse(:category_result, result_url).each do |result|
        competition.category_results.create do |cr|
          cr.attributes = result.except(:skater_name, :nation)
          cr.category = category
          skater_name = Skater.correct_name(result[:skater_name])
          cr.skater = Skater.find_or_create_by_isu_number_or_name(cr.isu_number, skater_name) do |sk|
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
  private
  def save_skater
    skater.save! if skater.present? && skater.changed?
    #self[:skater_name] = skater.name if skater
    self
  end
end
