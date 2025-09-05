# frozen_string_literal: true

module Api
  module V1
    module Workflow
      class BookingRequestsController < ApplicationController
        before_action :set_booking_request, only: [:show]

        def index
          booking_requests = ::Workflow::BookingRequest.page(params[:page]).per(params[:per_page] || 10)
          render json: booking_requests, each_serializer: ::V1::Workflow::BookingRequestSerializer,
                 meta: pagination_meta(booking_requests)
        end

        def show
          render json: @booking_request, serializer: ::V1::Workflow::BookingRequestSerializer
        end

        private

        def set_booking_request
          @booking_request = ::Workflow::BookingRequest.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Booking request not found' }, status: :not_found
        end
      end
    end
  end
end
