class Category < ApplicationRecord
  # has_many :category_results, dependent: :nullify
  # has_many :segment_results, dependent: :nullify
  # has_many :scores, dependent: :nullify
  # has_many :skaters, dependent: :nullify

  alias_attribute :category_name, :name

  scope :having_isu_bio, -> { select(&:isu_bio_url) }
end

## to be created in db/seeds.rb
