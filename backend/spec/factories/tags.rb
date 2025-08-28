FactoryBot.define do
  factory :tag do
    association :picture
    association :user
    x_frac { rand.round(3) }
    y_frac { rand.round(3) }
  end
end
