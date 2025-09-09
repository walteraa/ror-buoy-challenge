# frozen_string_literal: true

module Api
  module V1
    class AccommodationsController < ApplicationController
      before_action :set_accommodation, only: %i[show book availability]

      def index
        accommodations = Accommodation.page(params[:page]).per(params[:per_page] || 10)
        render json: accommodations, each_serializer: ::AccommodationSerializer, meta: pagination_meta(accommodations)
      end

      def show
        render json: @accommodation
      end

      def book
        booking_params = params.permit(:start_date, :end_date, :guest_name)

        booking_request = ::Workflow::BookingRequest.create!(
          accommodation_id: params[:id],
          params: booking_params.to_h,
          status: 'pending',
          requested_at: Time.current
        )

        ::Workflow::BookingCreationJob.perform_async(booking_request.id, booking_request.accommodation_id)

        render json: { message: 'Booking request created', booking_request_id: booking_request.id }, status: :accepted
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def availability
        from_date = begin
          Date.parse(params[:from_date])
        rescue ArgumentError, TypeError
          nil
        end

        return render json: { error: 'Invalid or missing from_date' }, status: :bad_request unless from_date

        # Fetch all bookings that overlap or come after from_date
        bookings = @accommodation.bookings
                                 .where('end_date >= ?', from_date)
                                 .order(:start_date)

        next_available = ComputeNextAvailability.call(from_date, bookings)

        render json: { accommodation_id: @accommodation.id, next_available: next_available }
      end

      private

      def set_accommodation
        @accommodation = Accommodation.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {}, status: :not_found
      end
    end
  end
end
