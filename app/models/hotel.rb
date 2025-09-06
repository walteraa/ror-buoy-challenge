# frozen_string_literal: true

class Hotel < ApplicationRecord
  include HasAmenities
  has_many :rooms, dependent: :destroy

  has_and_belongs_to_many :amenities

  accepts_nested_attributes_for :rooms, allow_destroy: true

  validates :name, presence: true

  scope :available, lambda { |start_date, end_date|
    joins(:rooms)
      .left_outer_joins(rooms: :bookings)
      .group('hotels.id')
      .having(
        'COUNT(bookings.id) = 0 OR COUNT(CASE WHEN bookings.start_date <= ? AND bookings.end_date >= ? THEN 1 END) < COUNT(accommodations.id)',
        end_date,
        start_date
      )
  }

  scope :with_amenities, lambda { |names|
    hotel_ids_from_hotels = joins(:amenities)
                            .where(amenities: { name: names })
                            .group('hotels.id')
                            .having('COUNT(DISTINCT amenities.id) = ?', names.size)
                            .select(:id)

    hotel_ids_from_rooms = joins(rooms: :amenities)
                           .where(amenities: { name: names })
                           .group('hotels.id')
                           .having('COUNT(DISTINCT amenities.id) = ?', names.size)
                           .select(:id)

    where(id: hotel_ids_from_hotels).or(where(id: hotel_ids_from_rooms)).distinct
  }
end
