class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :iso2, null: false, limit: 2
      t.string :iso3, limit: 3
      t.string :name_en, null: false
      t.string :name_es
      t.string :numeric_code, limit: 3
      t.string :calling_code
      t.string :region
      t.string :subregion

      t.timestamps
    end
    add_index :countries, :iso2, unique: true
    add_index :countries, :iso3, unique: true
  end
end
