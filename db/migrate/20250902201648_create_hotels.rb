# frozen_string_literal: true

class CreateHotels < ActiveRecord::Migration[7.1]
  def change
    create_table :hotels do |t|
      t.string :address
      t.string :name

      t.timestamps
    end
  end
end
