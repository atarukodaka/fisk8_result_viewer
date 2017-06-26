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
=begin
  scope :search_by, ->(skater_name:, segment:, ranking: ){
    ranking_type = (score[:segment] =~ /^SHORT/) ? :short_ranking : :free_ranking
    joins(:skater).where("skaters.name" => score[:skater_name]) || where(ranking_type => score[:ranking])
  }
=end

  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end

  class << self
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
