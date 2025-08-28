class Location < ApplicationRecord
  belongs_to :country

  has_many :trip_locations, dependent: :destroy, inverse_of: :location
  has_many :trips, through: :trip_locations
  has_many :posts, through: :trip_locations

  has_one_attached :photo

  validates :name, presence: true
  validates :normalized_name, presence: true
  validates :normalized_name, uniqueness: { scope: :country_id }

  before_validation :set_normalized_name

  private

  def set_normalized_name
    return if name.blank?
    self.normalized_name = I18n.transliterate(name.to_s).downcase.strip
  end
end
