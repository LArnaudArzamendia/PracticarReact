FactoryBot.define do
  factory :country do
    sequence(:name_en) { |n| "Country #{n}" }
    sequence(:name_es) { |n| "País #{n}" }

    sequence(:iso2) do |n|
      letters = ('A'..'Z').to_a
      letters[n % 26] + letters[(n / 26) % 26] # AA, BA, CA, ...
    end
    sequence(:iso3) do |n|
      letters = ('A'..'Z').to_a
      letters[n % 26] + letters[(n / 26) % 26] + letters[(n / 676) % 26]
    end
    sequence(:numeric_code) { |n| 100 + n }
  end
end
