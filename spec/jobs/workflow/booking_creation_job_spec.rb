# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::BookingCreationJob, type: :job do
  let(:booking_request) do
    Workflow::BookingRequest.create!(
      params: { 'start_date' => '2025-09-10', 'end_date' => '2025-09-12', 'guest_name' => 'John Doe' },
      status: 'pending',
      accommodation_id: create(:accommodation).id,
      requested_at: Time.current
    )
  end

  before do
    allow(Workflow::BookingRequest).to receive(:find).with(booking_request.id).and_return(booking_request)
  end

  describe '#perform' do
    context 'when there is no overlap' do
      it 'creates a booking and marks the request as success' do
        expect(booking_request).to receive(:mark_success) do |booking|
          expect(booking).to be_a(Booking)
          expect(booking.guest_name).to eq('John Doe')
        end

        described_class.new.perform(booking_request.id, booking_request.accommodation_id)
      end
    end

    context 'when there is an overlapping booking' do
      before do
        # simulate overlapping booking in the DB
        Booking.create!(
          start_date: '2025-09-10',
          end_date: '2025-09-12',
          guest_name: 'Someone Else',
          accommodation_id: booking_request.accommodation_id
        )
      end

      it 'does not create a booking and marks the request as failed' do
        expect(booking_request).to receive(:mark_failed).with(/Constraint violation: booking overlap/)

        described_class.new.perform(booking_request.id, booking_request.accommodation_id)
      end
    end

    context 'when ActiveRecord::RecordNotUnique is raised' do
      it 'marks the request as failed due to constraint violation' do
        allow(Workflow::BookingRequest).to receive(:find).and_return(booking_request)
        allow(Booking).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)

        expect(booking_request).to receive(:mark_failed).with(/Constraint violation: booking overlap/)

        described_class.new.perform(booking_request.id, booking_request.accommodation_id)
      end
    end

    context 'when an unknown error occurs' do
      it 'marks the request as failed with the error message' do
        allow(Workflow::BookingRequest).to receive(:find).and_return(booking_request)
        allow(Booking).to receive(:create!).and_raise('Boom!')

        expect(booking_request).to receive(:mark_failed).with(/Unknown error: Boom!/)

        described_class.new.perform(booking_request.id, booking_request.accommodation_id)
      end
    end
  end
  describe 'Sidekiq unique_args configuration' do
    it 'considers only accommodation_id for uniqueness' do
      job_class = described_class
      args = [123, 456] # booking_request_id, accommodation_id
      unique_args = job_class.get_sidekiq_options['unique_args'].call(args)
      expect(unique_args).to eq([456])
    end

    it 'does not consider booking_request_id for uniqueness' do
      job_class = described_class
      args = [999, 42]
      unique_args = job_class.get_sidekiq_options['unique_args'].call(args)
      expect(unique_args).to eq([42])
    end
  end
end
