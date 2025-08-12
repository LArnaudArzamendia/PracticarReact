class Tag < ApplicationRecord
  belongs_to :picture
  belongs_to :user

  validates :user_id, uniqueness: { scope: :picture_id }
  validates :x_frac, :y_frac,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 },
            allow_nil: true
end
