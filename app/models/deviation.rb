class Deviation < ApplicationRecord
  belongs_to :score
  belongs_to :official

  def self.enabled?
      (self.count > 0) ? true : false
  end
  
  delegate :name, to: :score, prefix: :score
  delegate :category_name, to: :score
  delegate :panel_name, to: :official
  delegate :panel_nation, to: :official
  delegate :skater_name, to: :score
  delegate :nation, to: :score, prefix: :skater
  delegate :number, to: :official, prefix: :official

end
