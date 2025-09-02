# spec/factories/trips.rb
FactoryBot.define do
  factory :trip do
    association :user
    title       { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }

    # Asegura coherencia entre fechas
    starts_on { Faker::Date.backward(days: 30) }
    ends_on   { starts_on + rand(1..20).days }

    public { false }

    # ---- Traits útiles ----

    trait :with_cover_photo do
      after(:build) do |trip|
        trip.cover_photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/plane_ticket.png")),
          filename: "sample.png",
          content_type: "image/png"
        )
      end
    end

    # Crea N paradas (Location + TripLocation con position incremental)
    trait :with_itinerary do
      transient do
        stops_count { 3 }
      end

      after(:create) do |trip, evaluator|
        evaluator.stops_count.times do |i|
          loc = create(:location)
          create(:trip_location, trip: trip, location: loc, position: i + 1)
        end
      end
    end

    # Crea N posts distribuidos en el viaje
    trait :with_posts do
      transient do
        posts_count { 2 }
      end

      after(:create) do |trip, evaluator|
        # Asegura al menos 1 location para asociar posts
        locations = if trip.locations.any?
                      trip.locations.to_a
                    else
                      [ create(:location).tap { |loc| 
                          create(:trip_location,
                            :trip, 
                            location: loc,
                            position: 1) 
                          }
                      ]
                    end

        evaluator.posts_count.times do
          create(:post, trip: trip, user: trip.user, location: locations.sample)
        end
      end
    end
  end
end
