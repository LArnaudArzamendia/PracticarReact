class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.references :picture, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.decimal :x_frac, precision: 4, scale: 3, null: true
      t.decimal :y_frac, precision: 4, scale: 3, null: true

      t.timestamps
    end
    add_index :tags, [ :picture_id, :user_id ], unique: true
    add_check_constraint :tags, "x_frac BETWEEN 0 AND 1", name: "chk_tags_x_frac_0_1"
    add_check_constraint :tags, "y_frac BETWEEN 0 AND 1", name: "chk_tags_y_frac_0_1"
  end
end
