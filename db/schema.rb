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

ActiveRecord::Schema[7.0].define(version: 2023_06_28_041210) do
  create_table "bookings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "room_id"
    t.integer "hotel_id"
    t.string "roomType"
    t.integer "numRoomsBooked"
    t.float "price"
    t.date "checkInDate"
    t.date "checkOutDate"
    t.boolean "isCancelled"
    t.index ["hotel_id"], name: "index_bookings_on_hotel_id"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.integer "manager_id"
    t.string "name"
    t.string "address"
    t.string "description"
    t.index ["manager_id"], name: "index_hotels_on_manager_id"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phoneNumber"
    t.string "password"
    t.string "employee_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "booking_id"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_ratings_on_booking_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "hotel_id"
    t.string "roomType"
    t.float "cost"
    t.integer "totalAvailable"
    t.index ["hotel_id"], name: "index_rooms_on_hotel_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password"
  end

  add_foreign_key "bookings", "hotels"
  add_foreign_key "bookings", "rooms"
  add_foreign_key "bookings", "users"
  add_foreign_key "hotels", "managers"
  add_foreign_key "ratings", "bookings"
  add_foreign_key "rooms", "hotels"
end
