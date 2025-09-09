# frozen_string_literal: true

class ComputeNextAvailability
  def self.call(from_date, bookings)
    # When there's no bookings >= from_date
    return from_date if bookings.blank?

    # starts from from_date
    current_date = from_date

    bookings.each do |booking|
      # Checks if a gap exists before the start_date
      return { 'from' => current_date, 'to' => booking.start_date - 1.day } if current_date < booking.start_date

      # Otherwise, move the current_date to the day after this booking
      current_date = [current_date, booking.end_date + 1.day].max
    end

    # If all bookings are continuous, availability starts after the last one
    { 'from' => current_date, 'to' => nil }
  end
end
