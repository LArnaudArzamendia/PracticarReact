# app/models/travel_buddy.rb
class TravelBuddy < ApplicationRecord
  belongs_to :trip
  belongs_to :user
  belongs_to :met_location, class_name: "Location", optional: true

  validates :trip_id, uniqueness: { scope: :user_id }
  validates :can_post, inclusion: { in: [ true, false ] }

  before_validation :prevent_self_buddy

  private
  def prevent_self_buddy
    return unless trip_id && user_id
    owner_id = trip&.user_id || Trip.where(id: trip_id).pick(:user_id)
    if owner_id.present? && user_id == owner_id
      errors.add(:user_id, "no puede ser compañero de su propio viaje")
      throw :abort
    end
  end
end
