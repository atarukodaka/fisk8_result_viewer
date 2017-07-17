class Result < ApplicationRecord
  ## relations
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater

  ## methods
  def competition_name
    competition.name
  end
  def competition_class
    competition.competition_class
  end
  def competition_type
    competition.competition_type
  end
  def season
    competition.season
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
    #scores.where("scores.segment like ?", 'SHORT%').first
  end
  def free
    #scores.where("scores.segment like ?", 'FREE%').first
    scores.second
  end
  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }

  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category, self.ranking, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end
  def update(parsed)
    attrs = self.class.column_names.map(&:to_sym) & parsed.keys
    self.attributes = parsed.slice(*attrs)
    ActiveRecord::Base.transaction {
      self.skater = Skater.find_or_create_by_isu_number_or_name(isu_number, parsed[:skater_name]) do |sk|
        sk.attributes = {
          category: category.sub(/^JUNIOR */, ''),
          nation: parsed[:nation],
        }
      end
      save!
    }
  end

  class << self
    def find_by_skater_name(skater_name)
      joins(:skater).find_by("skaters.name" => skater_name)
    end
    def find_by_segment_ranking(segment, ranking)
      ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
      where(ranking_type => ranking).first
    end
  end
end
