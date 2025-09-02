class CreateTrips < ActiveRecord::Migration[8.0]
  def change
    create_table :trips do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.date :starts_on
      t.date :ends_on
      t.boolean :public

      t.timestamps
    end
    change_column_null :trips, :user_id, false
    change_column_null :trips, :title,   false
    add_index :trips, [ :user_id, :created_at ]
  end
end
