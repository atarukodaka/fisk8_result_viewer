class GrandprixEvent < ApplicationRecord
  has_many :grandprix_entries, dependent: :destroy
  has_many :skaters, through: :grandprix_entries

  belongs_to :category
end
