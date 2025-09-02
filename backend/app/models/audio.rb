class Audio < ApplicationRecord
  belongs_to :post
  validates :post_id, presence: true
  has_one_attached :file
end
