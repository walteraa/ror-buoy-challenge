# frozen_string_literal: true

class CreateJoinTableAmenitiesAccomodations < ActiveRecord::Migration[7.1]
  def change
    create_table :accommodations_amenities, id: false do |t|
      t.bigint :accommodation_id, null: false
      t.bigint :amenity_id, null: false
    end

    add_index :accommodations_amenities, %i[accommodation_id amenity_id], unique: true
    add_index :accommodations_amenities, %i[amenity_id accommodation_id], unique: true
  end
end
