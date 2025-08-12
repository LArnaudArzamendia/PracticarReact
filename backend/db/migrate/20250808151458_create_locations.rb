class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string  :name, null: false
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :country, null: false, foreign_key: true
      t.timestamps
    end
    change_column_null :locations, :country_id, false
    change_column_null :locations, :name,       false
    add_index :locations, :name
    add_index :locations, [ :country_id, :name ]
  end
end
