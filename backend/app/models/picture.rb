class Picture < ApplicationRecord
  belongs_to :post
  has_one_attached :file
  has_many :tags, dependent: :destroy
end
