class Score < ApplicationRecord
  after_initialize :set_default_values

  ## relations
  has_many :elements, dependent: :destroy
  has_many :components, dependent: :destroy

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, required: false

  ## validations
  validates :sid, presence: true, uniqueness: true

  ## scopes
  scope :recent, ->{ order("date desc") }
  scope :short, -> { matches(:segment, "SHORT") }
  scope :free, -> { matches(:segment, "FREE") }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(c, s){ category(c).where(segment: s) }

  def to_s
    "    %s-%s [%2d] %-40s (%6d)[%s] | %6.2f = %6.2f + %6.2f + %2d" % [self.category, self.segment, self.ranking, self.skater.name, self.skater.isu_number.to_i, self.skater.nation, self.tss.to_f, self.tes.to_f, self.pcs.to_f, self.deductions.to_i]
  end
  
  private
  def set_default_values
    self.sid ||= [self.competition.cid, self.category, self.segment, self.ranking].join("-")
  end
end

