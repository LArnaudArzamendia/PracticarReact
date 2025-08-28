# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_11_134336) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audios", force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_audios_on_post_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "iso2", limit: 2, null: false
    t.string "iso3", limit: 3
    t.string "name_en", null: false
    t.string "name_es"
    t.string "numeric_code", limit: 3
    t.string "calling_code"
    t.string "region"
    t.string "subregion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iso2"], name: "index_countries_on_iso2", unique: true
    t.index ["iso3"], name: "index_countries_on_iso3", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "normalized_name"
    t.index ["country_id", "name"], name: "index_locations_on_country_id_and_name"
    t.index ["country_id", "normalized_name"], name: "idx_locations_country_normname_unique", unique: true
    t.index ["country_id"], name: "index_locations_on_country_id"
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_pictures_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "trip_location_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_location_id", "created_at"], name: "index_posts_on_trip_location_id_and_created_at"
    t.index ["trip_location_id"], name: "index_posts_on_trip_location_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "picture_id", null: false
    t.integer "user_id", null: false
    t.decimal "x_frac", precision: 4, scale: 3
    t.decimal "y_frac", precision: 4, scale: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["picture_id", "user_id"], name: "index_tags_on_picture_id_and_user_id", unique: true
    t.index ["picture_id"], name: "index_tags_on_picture_id"
    t.index ["user_id"], name: "index_tags_on_user_id"
    t.check_constraint "x_frac BETWEEN 0 AND 1", name: "chk_tags_x_frac_0_1"
    t.check_constraint "y_frac BETWEEN 0 AND 1", name: "chk_tags_y_frac_0_1"
  end

  create_table "travel_buddies", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.integer "user_id", null: false
    t.integer "met_location_id"
    t.date "met_on"
    t.boolean "can_post", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["met_location_id"], name: "index_travel_buddies_on_met_location_id"
    t.index ["trip_id", "user_id"], name: "index_travel_buddies_on_trip_id_and_user_id", unique: true
    t.index ["trip_id"], name: "index_travel_buddies_on_trip_id"
    t.index ["user_id"], name: "index_travel_buddies_on_user_id"
  end

  create_table "trip_locations", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.integer "location_id", null: false
    t.integer "position", null: false
    t.datetime "visited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_trip_locations_on_location_id"
    t.index ["trip_id", "location_id"], name: "index_trip_locations_on_trip_id_and_location_id", unique: true
    t.index ["trip_id", "position"], name: "index_trip_locations_on_trip_id_and_position", unique: true
    t.index ["trip_id"], name: "index_trip_locations_on_trip_id"
    t.check_constraint "position > 0", name: "chk_trip_locations_position_gt_zero"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "starts_on"
    t.date "ends_on"
    t.boolean "public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_trips_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "handle", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "country_id"
    t.string "jti", null: false
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_videos_on_post_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audios", "posts"
  add_foreign_key "locations", "countries"
  add_foreign_key "pictures", "posts"
  add_foreign_key "posts", "trip_locations"
  add_foreign_key "posts", "users"
  add_foreign_key "tags", "pictures"
  add_foreign_key "tags", "users"
  add_foreign_key "travel_buddies", "locations", column: "met_location_id"
  add_foreign_key "travel_buddies", "trips"
  add_foreign_key "travel_buddies", "users"
  add_foreign_key "trip_locations", "locations"
  add_foreign_key "trip_locations", "trips"
  add_foreign_key "trips", "users"
  add_foreign_key "users", "countries"
  add_foreign_key "videos", "posts"
end
