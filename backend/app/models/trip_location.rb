class TripLocation < ApplicationRecord
  belongs_to :trip
  belongs_to :location

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  # visited_at: datetime opcional para check-in
end
