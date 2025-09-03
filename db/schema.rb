# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_250_902_205_331) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'accommodations', force: :cascade do |t|
    t.string 'name'
    t.text 'description'
    t.decimal 'price', precision: 10, scale: 2
    t.string 'location'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'type'
    t.integer 'capacity'
    t.string 'address'
    t.bigint 'hotel_id'
    t.index ['hotel_id'], name: 'index_accommodations_on_hotel_id'
  end

  create_table 'accommodations_amenities', id: false, force: :cascade do |t|
    t.bigint 'accommodation_id', null: false
    t.bigint 'amenity_id', null: false
    t.index %w[accommodation_id amenity_id], name: 'idx_on_accommodation_id_amenity_id_79b44e830c', unique: true
    t.index %w[amenity_id accommodation_id], name: 'idx_on_amenity_id_accommodation_id_091017d8dc', unique: true
  end

  create_table 'amenities', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_amenities_on_name', unique: true
  end

  create_table 'amenities_hotels', id: false, force: :cascade do |t|
    t.bigint 'amenity_id', null: false
    t.bigint 'hotel_id', null: false
    t.index %w[amenity_id hotel_id], name: 'index_amenities_hotels_on_amenity_id_and_hotel_id'
    t.index %w[hotel_id amenity_id], name: 'index_amenities_hotels_on_hotel_id_and_amenity_id'
  end

  create_table 'bookings', force: :cascade do |t|
    t.bigint 'accommodation_id', null: false
    t.date 'start_date'
    t.date 'end_date'
    t.string 'guest_name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['accommodation_id'], name: 'index_bookings_on_accommodation_id'
  end

  create_table 'hotels', force: :cascade do |t|
    t.string 'address'
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'accommodations', 'hotels'
  add_foreign_key 'amenities_hotels', 'amenities'
  add_foreign_key 'amenities_hotels', 'hotels'
  add_foreign_key 'bookings', 'accommodations'
end
