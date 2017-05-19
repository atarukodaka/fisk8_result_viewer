class CategoryResult < ApplicationRecord
  belongs_to :competition
  belongs_to :skater

  scope :search_by_category, ->(cat) { where(category: cat) }
end
