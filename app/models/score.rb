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
  def elements_summary
    elements.map(&:name).join('/')
  end
  def components_summary
    components.map(&:value).join('/')
  end
  
  ## scopes
  scope :recent, ->{ order("date desc") }
  scope :short, -> { where("segment like ? ", "%SHORT%") }
  scope :free, ->  { where("segment like ? ", "%FREE%") }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(c, s){ category(c).where(segment: s) }

  ##
  class << self
    def create_score(score_url, competition, category, segment, attributes: {})
      #parser = Parsers.parser(:score, parser_type)
      parser = Parser::ScoreParser.new
      
      parser.parse(score_url).map do |score_hash|
        score = competition.scores.create do |sc|
          sc.attributes = score_hash.except(:skater_name, :nation, :elements, :components).merge(attributes).merge({category: category, segment: segment})
          results = competition.category_results
          sc.category_result = results.joins(:skater).find_by("skaters.name" => score_hash[:skater_name]) ||
            results.find_by_segment_ranking(segment, score_hash[:ranking]) || raise("score: no relevant category results found")
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

