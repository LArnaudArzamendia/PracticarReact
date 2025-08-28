FactoryBot.define do
  factory :picture do
    association :post
    caption { Faker::Lorem.sentence }
  end
end
