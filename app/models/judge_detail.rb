class JudgeDetail < ApplicationRecord
  belongs_to :detailable, polymorphic: true

  ## references
  belongs_to :official
  belongs_to :element, foreign_key: 'detailable_id', optional: true
  belongs_to :component, foreign_key: 'detailable_id', optional: true

  ## virtual attributes
  delegate :score_name, :goe, to: :element
  delegate :panel_name, to: :official
  delegate :skater_name, to: :score

  delegate :average, to: :detailable
  delegate :name, :number, to: :detailable, prefix: :detailable
  delegate :name, :number, to: :element, prefix: :element
  delegate :name, :number, to: :component, prefix: :component

  def deviation
    dev = value - detailable.average
    (detailable_type == 'Element') ? dev.abs : dev
  end

  private
end
