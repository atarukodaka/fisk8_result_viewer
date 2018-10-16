class Category < ApplicationRecord
  alias_attribute :category_name, :name

  scope :having_isu_bio, -> { select(&:isu_bio_url) }
end

## to be created in db/seeds.rb
