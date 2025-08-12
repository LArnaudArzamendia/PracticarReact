# app/models/user.rb
class User < ApplicationRecord
  belongs_to :country, optional: true

  has_many :trips, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :travel_buddies, dependent: :destroy
  has_many :buddy_trips, through: :travel_buddies, source: :trip
  has_many :tags, dependent: :destroy
  has_many :tagged_pictures, through: :tags, source: :picture

  has_one_attached :photo

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_cookie_authenticatable, :jwt_authenticatable,
         jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  validates :handle, presence: true, uniqueness: true, length: { maximum: 32 }
  validate  :handle_format

  before_create :ensure_jti
  before_validation :normalize_handle
  before_validation :ensure_handle

  private
  def ensure_jti
    self.jti ||= SecureRandom.uuid
  end

  def normalize_handle
    return if handle.blank?
    h = handle.to_s.strip.downcase
    h = "@#{h}" unless h.start_with?("@")
    self.handle = h
  end

  def handle_format
    return if handle.blank?
    # @ seguido de letras/números/._-
    errors.add(:handle, "formato inválido") unless handle.match?(/\A@[a-z0-9._-]+\z/)
  end

  def ensure_handle
    return if handle.present?
    base = (email&.split("@")&.first || "user").parameterize(separator: "_")
    # intenta algunos candidate únicos
    10.times do
      candidate = "@#{base}#{SecureRandom.hex(3)}"
      unless self.class.exists?(handle: candidate)
        self.handle = candidate
        return
      end
    end
    # último recurso
    self.handle = "@user#{SecureRandom.hex(6)}"
  end
end
