class Official < ApplicationRecord
  belongs_to :panel
  belongs_to :competition
  belongs_to :category
  belongs_to :segment

  ## references
  #belongs_to :performed_segment

  #  delegate :competition_name, :category_name, :segment_name, to: :performed_segment
  delegate :name, :nation, to: :panel, prefix: :panel

  # scope :absent, -> { where(absence: true) }
  # scope :attended, -> { where(absence: false) }

  def competition_name
    competition.name
  end

  def category_name
    category.name
  end

  def segment_name
    segment.name
  end
end
