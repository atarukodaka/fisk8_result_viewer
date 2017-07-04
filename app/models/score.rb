class Score < ApplicationRecord
  before_save :set_score_name  #, :set_skater_name
  
  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, required: false

  ## validations
  validates  :date, presence: true

  ## relevant model
  def competition_name
    competition.name
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
  
  ## scopes
  scope :recent, ->{ order("date desc") }
  scope :short, -> { matches(:segment, "SHORT") }
  scope :free, -> { matches(:segment, "FREE") }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(c, s){ category(c).where(segment: s) }

  ##
  class << self
    def create_score(score_url, competition, category, segment, parser: nil, attributes: {})
      parser ||= Parser::ScoreParser.new
      
      parser.parse(:score, score_url).map do |score_hash|
        score = competition.scores.create do |sc|
          sc.attributes = score_hash.except(:skater_name, :nation, :elements, :components).merge(attributes).merge({category: category, segment: segment})
          sc.category_result = competition.category_results.search_by_skater_name_or_segment_ranking(skater_name: Skater.correct_name(score_hash[:skater_name]), segment: segment, ranking: score_hash[:ranking]).first || raise  # TODO
          sc.skater = sc.category_result.skater
        end
        score_hash[:elements].map {|e| score.elements.create(e)}
        score_hash[:components].map {|e| score.components.create(e)}
        puts score.summary
        score
      end
    end
  end
  
  def summary
    skater_name = self.skater.try(:name) || self.skater_name
    nation = self.skater.try(:nation) || self.nation
    isu_number = self.skater.try(:isu_number) || 0
    
    "    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d" % [self.category, self.segment, self.ranking, skater_name.truncate(35), isu_number.to_i, nation, self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end

  private
  def set_score_name
    return if self[:name].present?
    category_abbr = self.category || ""
    [["MEN", "M"], ["LADIES", "L"], ["PAIRS", "P"], ["ICE DANCE", "D"],
     ["JUNIOR ", "J"]].each do |ary|
      key, abbr = ary
      category_abbr = category_abbr.gsub(key, abbr)
    end

    segment_abbr = self.segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'

    self[:name] = [self.competition.try(:short_name), category_abbr, segment_abbr, self.ranking].join('-')
    self
  end
end

