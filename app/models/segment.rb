class Segment < ApplicationRecord
  # has_many :segment_results, dependent: :nullify
  # has_many :scores, dependent: :nullify

  alias_attribute :segment_name, :name
end

## to be created in db/seeds.rb
