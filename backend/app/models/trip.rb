class Trip < ApplicationRecord
  belongs_to :user

  has_many :trip_locations, -> { order(:position) }, dependent: :destroy, inverse_of: :trip
  has_many :locations, through: :trip_locations
  has_many :posts, dependent: :destroy

  has_many :travel_buddies, dependent: :destroy
  has_many :buddies, through: :travel_buddies, source: :user

  has_one_attached :cover_photo

  validates :title, presence: true
end
