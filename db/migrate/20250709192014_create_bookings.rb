# frozen_string_literal: true

class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :accommodation, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :guest_name

      t.timestamps
    end
  end
end
