# frozen_string_literal: true

class AddExcludeConstraintToBookingsOverlap < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'btree_gist'
    execute <<-SQL
      ALTER TABLE bookings
      ADD CONSTRAINT bookings_no_overlap EXCLUDE USING gist
      (
        accommodation_id WITH =,
        daterange(start_date, end_date, '[]') WITH &&
      );
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE bookings
      DROP CONSTRAINT bookings_no_overlap;
    SQL
  end
end
