class JudgeDetail < ApplicationRecord
  belongs_to :detailable, polymorphic: true

  ## references
  belongs_to :official

  ## virtual attributes
  delegate :score_name, :goe, to: :element
  delegate :panel_name, to: :official
  delegate :name, :number, to: :element, prefix: :element
  delegate :skater_name, to: :score

  ## scope
  # scope :valid, -> { joins(:official).where("officials.absence": false) }

  def deviation
    dev = value - detailable.average
    (detailable_type == "Element") ? dev.abs : dev
  end
end
