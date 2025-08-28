FactoryBot.define do
  factory :post do
    association :user
    association :trip_location
    body { Faker::Lorem.paragraph }
  end
end
