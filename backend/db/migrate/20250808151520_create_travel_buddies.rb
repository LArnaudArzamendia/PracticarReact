class CreateTravelBuddies < ActiveRecord::Migration[8.0]
  def change
    create_table :travel_buddies do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :met_location, foreign_key: { to_table: :locations }

      t.date    :met_on
      t.boolean :can_post, default: false, null: false

      t.timestamps
    end

    add_index :travel_buddies, [ :trip_id, :user_id ], unique: true
  end
end
