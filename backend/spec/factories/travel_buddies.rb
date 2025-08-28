FactoryBot.define do
  factory :travel_buddy do
    association :trip
    association :user
    association :met_location, factory: :location
    met_on { Faker::Date.backward(days: 100) }
    can_post { false }
  end
end