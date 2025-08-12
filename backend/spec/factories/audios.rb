FactoryBot.define do
  factory :audio do
    association :post
    caption { Faker::Lorem.sentence }
  end
end
