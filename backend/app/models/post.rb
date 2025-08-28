class Post < ApplicationRecord
  belongs_to :user
  belongs_to :trip_location
  has_one :trip, through: :trip_location
  has_one :location, through: :trip_location

  has_many :pictures, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :audios, dependent: :destroy
end
