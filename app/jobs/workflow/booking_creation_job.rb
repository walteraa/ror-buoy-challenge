# frozen_string_literal: true

module Workflow
  class BookingCreationJob
    include Sidekiq::Worker

    sidekiq_options queue: 'booking_queue',
                    unique: :while_executing,
                    unique_args: ->(args) { [args[1]] }, # consider only the accommodation_id as unique key
                    retry: false

    def perform(booking_request_id, accommodation_id)
      booking_request = BookingRequest.find(booking_request_id)
      params = booking_request.params

      start_date = Date.parse(params['start_date'])
      end_date = Date.parse(params['end_date'])
      guest_name = params['guest_name']

      overlap = Booking.where(accommodation_id: accommodation_id)
                       .where('start_date < ? AND end_date > ?', end_date, start_date)
                       .exists?

      if overlap
        booking_request.mark_failed(' Constraint violation: booking overlap')
        return
      end

      begin
        booking = Booking.create!(
          accommodation_id: accommodation_id,
          start_date: start_date,
          end_date: end_date,
          guest_name: guest_name
        )
        booking_request.mark_success(booking)
      rescue ActiveRecord::RecordNotUnique
        booking_request.mark_failed('Constraint violation: booking overlap')
      rescue StandardError => e
        booking_request.mark_failed("Unknown error: #{e.message}")
      end
    end
  end
end
