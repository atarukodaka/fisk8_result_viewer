class Official < ApplicationRecord
  belongs_to :panel
  belongs_to :performed_segment
end
