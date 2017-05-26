class CategoryResult < ApplicationRecord
  has_many :scores
  
  belongs_to :competition
  belongs_to :skater

  scope :with_competition, ->{ joins(:competition) }
  scope :recent, ->{ with_competition.order("competitions.start_date desc") }

  scope :search_by_category, ->(cat) { where(category: cat) }

=begin
  def short
    Score.where(competition_id: competition.id, category: self.category).where("segment like ?", "SHORT%").first
  end

  def free
    Score.where(competition_id: competition.id, category: self.category).where("segment like ?", "FREE%").first
  end
=end
end
