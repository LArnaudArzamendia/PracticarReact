FactoryBot.define do
  factory :location do
    association :country
    name { Faker::Address.city }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    trait :with_photo do
      after(:build) do |location|
        location.photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/map_pin.png")),
          filename: "sample.png",
          content_type: "image/png"
        )
      end
    end
  end
end
