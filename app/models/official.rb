class Official < ApplicationRecord
  belongs_to :panel

  ## references
  belongs_to :performed_segment

  delegate :competition_name, to: :performed_segment
  delegate :category_name, to: :performed_segment
  delegate :segment_name, to: :performed_segment
  delegate :name, to: :panel, prefix: :panel
  delegate :nation, to: :panel, prefix: :panel
end
