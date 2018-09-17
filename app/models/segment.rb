class Segment < ApplicationRecord
  has_many :segment_results
  has_many :scores
end

## to be created in db/seeds.rb
