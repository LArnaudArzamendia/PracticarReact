FactoryBot.define do
  factory :video do
    association :post
    caption { Faker::Lorem.sentence }
  end
end
