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

ActiveRecord::Schema[7.2].define(version: 2026_04_22_200347) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "device_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "fcm_token", null: false
    t.string "platform", null: false
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fcm_token"], name: "index_device_tokens_on_fcm_token", unique: true
    t.index ["user_id"], name: "index_device_tokens_on_user_id"
  end

  create_table "leader_claims", force: :cascade do |t|
    t.bigint "ride_id", null: false
    t.bigint "user_id", null: false
    t.datetime "claimed_at", null: false
    t.datetime "released_at"
    t.datetime "last_ping_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_id"], name: "index_leader_claims_on_ride_id"
    t.index ["ride_id"], name: "index_leader_claims_on_ride_id_active", unique: true, where: "(released_at IS NULL)"
    t.index ["user_id"], name: "index_leader_claims_on_user_id"
  end

  create_table "location_pings", force: :cascade do |t|
    t.bigint "ride_id", null: false
    t.bigint "user_id", null: false
    t.decimal "lat", precision: 10, scale: 7, null: false
    t.decimal "lng", precision: 10, scale: 7, null: false
    t.decimal "heading", precision: 6, scale: 2
    t.decimal "speed", precision: 6, scale: 2
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_id", "recorded_at"], name: "index_location_pings_on_ride_id_and_recorded_at"
    t.index ["ride_id"], name: "index_location_pings_on_ride_id"
    t.index ["user_id"], name: "index_location_pings_on_user_id"
  end

  create_table "notifications_logs", force: :cascade do |t|
    t.bigint "ride_id", null: false
    t.bigint "subscription_id", null: false
    t.string "kind", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_id", "subscription_id", "kind"], name: "index_notifications_logs_dedupe", unique: true
    t.index ["ride_id"], name: "index_notifications_logs_on_ride_id"
    t.index ["subscription_id"], name: "index_notifications_logs_on_subscription_id"
  end

  create_table "rides", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.bigint "schedule_id"
    t.datetime "scheduled_start_at", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id", "scheduled_start_at"], name: "index_rides_on_route_id_and_scheduled_start_at"
    t.index ["route_id"], name: "index_rides_on_route_id"
    t.index ["schedule_id"], name: "index_rides_on_schedule_id"
    t.index ["status"], name: "index_rides_on_status"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "school_name", null: false
    t.geography "path_geojson", limit: {srid: 4326, type: "geometry", geographic: true}
    t.string "visibility", default: "public", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_routes_on_active"
    t.index ["creator_id"], name: "index_routes_on_creator_id"
    t.index ["visibility"], name: "index_routes_on_visibility"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.integer "days_of_week", default: [], null: false, array: true
    t.time "start_time", null: false
    t.string "timezone", default: "UTC", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_schedules_on_route_id"
  end

  create_table "stops", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.integer "position", null: false
    t.string "name", null: false
    t.decimal "lat", precision: 10, scale: 7, null: false
    t.decimal "lng", precision: 10, scale: 7, null: false
    t.integer "scheduled_offset_minutes", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id", "position"], name: "index_stops_on_route_id_and_position"
    t.index ["route_id"], name: "index_stops_on_route_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "route_id", null: false
    t.bigint "pickup_stop_id", null: false
    t.boolean "notify_schedule", default: true, null: false
    t.boolean "notify_depart", default: true, null: false
    t.boolean "notify_approach", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pickup_stop_id"], name: "index_subscriptions_on_pickup_stop_id"
    t.index ["route_id"], name: "index_subscriptions_on_route_id"
    t.index ["user_id", "route_id"], name: "index_subscriptions_on_user_id_and_route_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "display_name", default: "", null: false
    t.string "phone"
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "device_tokens", "users"
  add_foreign_key "leader_claims", "rides"
  add_foreign_key "leader_claims", "users"
  add_foreign_key "location_pings", "rides"
  add_foreign_key "location_pings", "users"
  add_foreign_key "notifications_logs", "rides"
  add_foreign_key "notifications_logs", "subscriptions"
  add_foreign_key "rides", "routes"
  add_foreign_key "rides", "schedules"
  add_foreign_key "routes", "users", column: "creator_id"
  add_foreign_key "schedules", "routes"
  add_foreign_key "stops", "routes"
  add_foreign_key "subscriptions", "routes"
  add_foreign_key "subscriptions", "stops", column: "pickup_stop_id"
  add_foreign_key "subscriptions", "users"
end
