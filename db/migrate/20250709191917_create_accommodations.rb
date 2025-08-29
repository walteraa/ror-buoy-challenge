class CreateAccommodations < ActiveRecord::Migration[7.1]
  def change
    create_table :accommodations do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision:10, scale: 2
      t.string :location

      t.timestamps
    end
  end
end
