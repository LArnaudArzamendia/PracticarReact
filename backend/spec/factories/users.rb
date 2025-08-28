# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    association :country
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:handle) { |n| "@user#{n}" }
    password { "password123" }
    password_confirmation { password } # asegura que Devise pase la validación
    jti { SecureRandom.uuid }

    # Si en tests quieres un usuario ya con foto:
    trait :with_photo do
      after(:build) do |user|
        user.photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/sample_user.png")),
          filename: "sample.png",
          content_type: "image/png"
        )
      end
    end
  end
end
