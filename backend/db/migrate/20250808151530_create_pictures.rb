class CreatePictures < ActiveRecord::Migration[8.0]
  def change
    create_table :pictures do |t|
      t.references :post, null: false, foreign_key: true
      t.string :caption

      t.timestamps
    end
    change_column_null :pictures, :post_id, false
  end
end
