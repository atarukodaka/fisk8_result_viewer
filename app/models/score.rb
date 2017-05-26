class Score < ApplicationRecord
  after_initialize :set_default_values
  
  has_many :elements, dependent: :destroy
  has_many :components, dependent: :destroy

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, required: false

  validates :sid, presence: true, uniqueness: true
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  
  
  scope :recent, ->{ order("date desc") }

  private
  def set_default_values
    self.sid ||= [self.competition.cid, self.category, self.segment, self.ranking].join("-")
  end
end

