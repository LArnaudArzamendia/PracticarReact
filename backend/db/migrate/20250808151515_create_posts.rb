class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip_location, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end

    add_index :posts, [:trip_location_id, :created_at]
  end
end
