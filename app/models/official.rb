class Official < ApplicationRecord
  belongs_to :panel

  ## references
  belongs_to :performed_segment

  delegate :competition_name, :category_name, :segment_name, to: :performed_segment
  delegate :name, :nation, to: :panel, prefix: :panel
end
