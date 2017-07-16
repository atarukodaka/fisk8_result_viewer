class Score < ApplicationRecord
  ## relations
  has_many :elements, dependent: :destroy, autosave: true
  has_many :components, dependent: :destroy, autosave: true

  belongs_to :competition
  belongs_to :skater
  belongs_to :result, required: false

  ## validations
  validates  :date, presence: true

  ## relevant model
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
  scope :segment, ->(s){ where(segment: s) }

  ##
  def update!(parsed)
    attrs = self.class.column_names.map(&:to_sym) & parsed.keys
    self.attributes = parsed.slice(*attrs)
    set_score_name
    ActiveRecord::Base.transaction {
      save!
      parsed[:elements].map {|e| elements.create(e)}
      parsed[:components].map {|e| components.create(e)}
    }
  end
  def summary
    skater_name = self.skater.try(:name) || self.skater_name
    nation = self.skater.try(:nation) || self.nation
    isu_number = self.skater.try(:isu_number) || 0
    
    "    %s-%s [%2d] %-35s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d" % [self.category, self.segment, self.ranking, skater_name.truncate(35), isu_number.to_i, nation, self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end

  private
  def set_score_name
    return if name.present?

    category_abbr = Category.find_by(name: category).try(:abbr)
    segment_abbr = segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'

    self.name = [competition.try(:short_name), category_abbr, segment_abbr, ranking].join('-')
    self
  end
end

