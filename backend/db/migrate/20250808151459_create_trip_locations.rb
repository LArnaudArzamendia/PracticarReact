class CreateTripLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :trip_locations do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.integer :position
      t.datetime :visited_at

      t.timestamps
    end
    change_column_null :trip_locations, :trip_id,     false
    change_column_null :trip_locations, :location_id, false
    change_column_null :trip_locations, :position,    false
    add_index :trip_locations, [ :trip_id, :position ],     unique: true
    add_index :trip_locations, [ :trip_id, :location_id ],  unique: true
    add_check_constraint :trip_locations, "position > 0", name: "chk_trip_locations_position_gt_zero"
  end
end
