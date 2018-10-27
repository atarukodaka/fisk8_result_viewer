class Deviation < ApplicationRecord
  before_save :_set_name

  belongs_to :score
  belongs_to :official

  alias_attribute :deviation_name, :name
  
  #delegate :name, to: :score, prefix: :score
  delegate :score_name, to: :score
  delegate :skater_name, :category_name, to: :score
  delegate :panel_name, :panel_nation, to: :official
  delegate :nation, to: :score, prefix: :skater
  delegate :number, to: :official, prefix: :official

  private

  def _set_name
    self.name = "#{score.name}-#{official.number}"
    self
  end
end
