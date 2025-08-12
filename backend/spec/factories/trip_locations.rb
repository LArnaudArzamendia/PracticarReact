FactoryBot.define do
  factory :trip_location do
    association :trip
    association :location
    sequence(:position) { |n| n }
    visited_at { Time.current }
  end
end