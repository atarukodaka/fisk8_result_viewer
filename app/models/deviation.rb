class Deviation < ApplicationRecord
  belongs_to :score
  belongs_to :official

  def self.enabled?
    (self.count.positive?) ? true : false
  end

  delegate :name, to: :score, prefix: :score
  delegate :skater_name, :category_name, to: :score
  delegate :panel_name, :panel_nation, to: :official
  delegate :nation, to: :score, prefix: :skater
  delegate :number, to: :official, prefix: :official
end
