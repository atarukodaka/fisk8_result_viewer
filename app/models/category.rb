class Category < ApplicationRecord
  has_many :category_results
  has_many :segment_results
  has_many :scores
  has_many :skaters

  #alias :category_name :name
  alias_attribute :category_name, :name
=begin
  def category_name
    name
  end
=end
end

## to be created in db/seeds.rb
