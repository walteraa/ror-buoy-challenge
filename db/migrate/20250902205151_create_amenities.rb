# frozen_string_literal: true

class CreateAmenities < ActiveRecord::Migration[7.1]
  def change
    create_table :amenities do |t|
      t.string :name

      t.timestamps
    end
    add_index :amenities, :name, unique: true
  end
end
