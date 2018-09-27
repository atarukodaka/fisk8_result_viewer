class Deviation < ApplicationRecord
  belongs_to :score
  belongs_to :panel
  belongs_to :official

  def self.enabled?
      (self.count > 0) ? true : false
  end
  
  delegate :name, to: :score, prefix: :score
  delegate :name, to: :panel, prefix: :panel
  delegate :skater_name, to: :score
  delegate :number, to: :official, prefix: :official

  def tes_ratio
    tes_deviation / num_elements
  end

  def pcs_ratio
    (pcs_deviation / 7.5).abs
  end
end
