class JudgeDetail < ApplicationRecord
  before_save :_validate_detailable

  belongs_to :detailable, polymorphic: true

  ## references
  belongs_to :official
  belongs_to :element, optional: true
  belongs_to :component,  optional: true

  ## virtual attributes
  delegate :score_name, :goe, to: :element
  delegate :panel_name, to: :official
  delegate :skater_name, to: :score

  delegate :average, to: :detailable
  delegate :name, :number, to: :detailable, prefix: :detailable
  delegate :name, :number, to: :element, prefix: :element
  delegate :name, :number, to: :component, prefix: :component

  ## scope
  # scope :valid, -> { joins(:official).where("officials.absence": false) }

  def deviation
    dev = value - detailable.average
    (detailable_type == 'Element') ? dev.abs : dev
  end

  private

  def _validate_detailable
    raise ActiveRecord::RecordInvalid.new(self.new) if element.nil? && component.nil?
  end
end
