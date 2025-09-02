class Country < ApplicationRecord
  validates :iso2, presence: true, length: { is: 2 }, uniqueness: true
  validates :name_en, presence: true
end
