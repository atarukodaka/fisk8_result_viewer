class Score < ApplicationRecord
  include FilterModules
  
  after_initialize :set_default_values
  
  has_many :elements, dependent: :destroy
  has_many :components, dependent: :destroy

  belongs_to :competition
  belongs_to :skater

  validates :sid, presence: true, uniqueness: true
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  
  
  scope :recent, ->{
    order("date desc")
  }
  private
  def set_default_values
    self.sid ||= [self.competition.try(:cid), self.category, self.segment, self.ranking].join("-")
  end
end

