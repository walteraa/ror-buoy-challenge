# frozen_string_literal: true

class CreateBookingRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :booking_requests do |t|
      t.json :params, null: false, default: {}
      t.string :status, null: false, default: 'pending'
      t.datetime :requested_at, null: false
      t.datetime :performed_at
      t.string :failure_reason
      t.references :booking, foreign_key: true
      t.references :accommodation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
