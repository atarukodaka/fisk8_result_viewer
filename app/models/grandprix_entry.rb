class GrandprixEntry < ApplicationRecord
  belongs_to :grandprix_event
  belongs_to :skater
end
