class Category < ApplicationRecord
  alias_attribute :category_name, :name

  scope :having_isu_bio, -> { select(&:isu_bio_url) }

  belongs_to :category_type
end

## actual data will be created in db/seeds.rb
