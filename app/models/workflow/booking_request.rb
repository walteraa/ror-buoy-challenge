# frozen_string_literal: true

module Workflow
  class BookingRequest < ApplicationRecord
    belongs_to :accommodation
    belongs_to :booking, optional: true

    STATUSES = %w[pending success failed].freeze

    validates :status, inclusion: { in: STATUSES }
    validates :params, presence: true
    validates :requested_at, presence: true

    def mark_success(booking)
      update!(status: 'success', booking_id: booking.id, performed_at: Time.current)
    end

    def mark_failed(reason)
      update!(status: 'failed', failure_reason: reason, performed_at: Time.current)
    end
  end
end
