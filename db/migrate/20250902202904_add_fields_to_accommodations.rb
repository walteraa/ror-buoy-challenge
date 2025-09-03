# frozen_string_literal: true

class AddFieldsToAccommodations < ActiveRecord::Migration[7.1]
  def change
    add_column :accommodations, :type, :string
    add_column :accommodations, :capacity, :integer
    add_column :accommodations, :address, :string

    # nullable since only hotels have rooms/accomodations
    add_reference :accommodations, :hotel, null: true, foreign_key: true
  end
end
