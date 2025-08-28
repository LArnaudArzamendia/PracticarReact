# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'csv'
path = Rails.root.join('db', 'data', 'countries.csv')
CSV.foreach(path, headers: true) do |row|
  Country.upsert(
    {
      iso2: row['iso2'],
      iso3: row['iso3'],
      name_en: row['name_en'],
      name_es: row['name_es'],
      numeric_code: row['numeric_code'],
      calling_code: row['calling_code'],
      region: row['region'],
      subregion: row['subregion'],
      updated_at: Time.current,
      created_at: Time.current
    },
    unique_by: :iso2
  )
end

User.create!(email: "traveller@miuandes.cl", password: "123123123", password_confirmation: "123123123", jti: SecureRandom.uuid)
