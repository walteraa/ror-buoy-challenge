# frozen_string_literal: true

module Api
  module V1
    class BookingsController < ApplicationController
      before_action :set_booking, only: %i[show update destroy]

      def index
        bookings = Booking.where(accommodation_id: params[:accommodation_id]).page(params[:page]).per(params[:per_page] || 10)
        render json: bookings, each_serializer: ::BookingSerializer, meta: pagination_meta(bookings)
      end

      def list
        bookings = Booking.all
        render json: bookings
      end

      def show
        render json: @booking
      end

      def update
        if @booking.update(booking_params)
          render json: @booking
        else
          render json: @booking.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @booking.destroy
        head :no_content
      end

      private

      def set_booking
        @booking = Booking.find(params[:id])
      end

      def booking_params
        params.require(:booking).permit(:accommodation_id, :start_date, :end_date, :guest_name)
      end
    end
  end
end
