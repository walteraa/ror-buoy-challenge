# frozen_string_literal: true

class Apartment < Accommodation
  include HasAmenities

  scope :available, lambda { |start_date, end_date|
    left_outer_joins(:bookings)
      .where(
        'bookings.id IS NULL OR NOT (bookings.start_date <= ? AND bookings.end_date >= ?)',
        end_date,
        start_date
      )
      .distinct
  }

  scope :with_amenities, lambda { |names|
    joins(:amenities)
      .where(amenities: { name: names })
      .group('accommodations.id')
      .having('COUNT(DISTINCT amenities.id) = ?', names.size)
  }
end
