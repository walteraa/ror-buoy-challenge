# frozen_string_literal: true

class CreateJoinTableAmenitiesHotels < ActiveRecord::Migration[7.1]
  def change
    create_join_table :amenities, :hotels do |t|
      t.index %i[amenity_id hotel_id]
      t.index %i[hotel_id amenity_id]
      t.foreign_key :amenities
      t.foreign_key :hotels
    end
  end
end
