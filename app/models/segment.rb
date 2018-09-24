class Segment < ApplicationRecord
  has_many :segment_results
  has_many :scores

  alias_attribute :segment_name, :name
end

## to be created in db/seeds.rb
