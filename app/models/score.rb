class Score < ApplicationRecord
  include IsuChampionshipsOnly
  
  after_initialize :set_default_values
  
  has_many :elements, dependent: :destroy
  has_many :components, dependent: :destroy

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, required: false

  validates :sid, presence: true, uniqueness: true
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  
  
  scope :recent, ->{ order("date desc") }
  scope :short, -> { matches(:segment, "SHORT") }
  scope :free, -> { matches(:segment, "FREE") }
  scope :category,->(c){ where(category: c) }
  scope :segment, ->(c, s){ category(c).where(segment: s) }
  
  private
  def set_default_values
    self.sid ||= [self.competition.cid, self.category, self.segment, self.ranking].join("-")
  end
end

