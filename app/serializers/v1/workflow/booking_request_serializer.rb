# frozen_string_literal: true

module V1
  module Workflow
    class BookingRequestSerializer < ActiveModel::Serializer
      type :booking_request

      attributes :id, :status, :accommodation_id, :params
    end
  end
end
