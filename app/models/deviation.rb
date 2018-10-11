class Deviation < ApplicationRecord
  belongs_to :score
  belongs_to :official

  delegate :name, to: :score, prefix: :score
  delegate :skater_name, :category_name, to: :score
  delegate :panel_name, :panel_nation, to: :official
  delegate :nation, to: :score, prefix: :skater
  delegate :number, to: :official, prefix: :official
end
