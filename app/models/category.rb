class Category < ApplicationRecord
  has_many :category_results
  has_many :segment_results
  has_many :scores
  has_many :skaters
end

## to be created in db/seeds.rb
