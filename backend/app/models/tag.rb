class Tag < ApplicationRecord
  belongs_to :picture
  belongs_to :user

  validates :x_frac, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates :y_frac, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
end
